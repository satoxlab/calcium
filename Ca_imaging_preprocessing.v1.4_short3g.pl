#!/usr/bin/perl

use strict;
use warnings;

use File::chdir;

# set a path to the directory containing required scripts.
# set ImageJ command according to your environment.
my $bin = "~/bin/";
my $ImageJ 
    = join (" ",
            "java -Xmx51200m -Xincgc -XX:+DisableExplicitGC",
            "-jar ~/ImageJ_ms/ImageJ64.app/Contents/Resources/Java/ij.jar",
            "-ijpath /home/calcium/ImageJ_ms -batch"
           );
my $R = "R --no-save --slave < ";

my ($base_dir) = @ARGV;
$base_dir =~ s/\/$//;
my @path_to_base_dir = split/\//, $base_dir;
my $log_file = $path_to_base_dir[$#path_to_base_dir] . "_log.txt";
my $stdout_file = $path_to_base_dir[$#path_to_base_dir] . "_out.txt";

$base_dir .= "/" if $base_dir !~ m/\/$/;
open my $log, ">", $base_dir . $log_file or die "$!";
print $log "Preprocessing started: " . &current_time() . "\n";

sub command_exercute {
    my ($cmd) = @_;
    print $log &current_time() . "\n" .
               $cmd . "\n\n";
    system ($cmd);
}

sub ImageJargs {
    return (join (":", @_));
}


{
    local $CWD = $base_dir;
    require $bin . "file_sorter.pl";

    opendir (my $in_dir, $base_dir);
    my @dir_and_files = readdir ($in_dir);
    closedir ($in_dir);

    my $single_tiff_directory = q{};
    my $R_GECO_multitiff      = q{};
    my $GFP_multitiff         = q{};

    for (0..$#dir_and_files){
        # adjust matching if necessary. In our cases, w000(0|1) and f0000 were in file names.
        if ($dir_and_files[$_] =~ m/^\./ || $dir_and_files[$_] =~ m/(w000n|f0000_test1)/){
             next;
        }
        else{
            print $dir_and_files[$_] . "\n";

            if ($dir_and_files[$_] !~ m/\.(tif{1,2}|txt)$/){
                $single_tiff_directory = $dir_and_files[$_];
            }
            elsif ($dir_and_files[$_] =~ m/w0000/){
                $GFP_multitiff = $dir_and_files[$_];
            }
            elsif ($dir_and_files[$_] =~ m/w0001/){
                $R_GECO_multitiff = $dir_and_files[$_];
            }
            elsif ($dir_and_files[$_] =~ m/_(log|out)((.(e|o))*).txt$/){
            }
            else{
                die "tiff file with unclear identity: $dir_and_files[$_]";
            }
       }
    }
#die $single_tiff_directory;
    my ($R_GECO_tiff_directory, $GFP_tiff_directory)
         = &sorting_files($single_tiff_directory);
    $R_GECO_tiff_directory .= "/" if $R_GECO_tiff_directory !~ m/\/$/;
    $GFP_tiff_directory    .= "/" if $GFP_tiff_directory !~ m/\/$/;

    my $R_GECO_txt_direcotry = $R_GECO_multitiff;
    $R_GECO_txt_direcotry    =~ s/\.tif+$/_txt\//;
    my $GFP_txt_directory    = $GFP_multitiff;
    $GFP_txt_directory       =~ s/\.tif+$/_txt\//;

    my $tif_to_txt = join (" ", $ImageJ, $bin . "batch_single_tif_to_txt.ijm");
    &command_exercute(join (" ", $tif_to_txt, 
                                 &ImageJargs($R_GECO_tiff_directory,
                                             $R_GECO_txt_direcotry
                                            ),
                                 ">> $stdout_file"
                           )
                     );
    &command_exercute(join (" ", $tif_to_txt,
                                 &ImageJargs( $GFP_tiff_directory,
                                              $GFP_txt_directory
                                            ),
                                 ">> $stdout_file"
                           )
                     );

    my $normalized_txt_directory = $R_GECO_txt_direcotry;
    $normalized_txt_directory    =~ s/w0001/w000n/;
    my $normalization_coef_file  = $normalized_txt_directory;
    $normalization_coef_file     =~ s/_txt\/$/_coef.txt/;
    
    my $normalization 
        = join (" ", $R, $bin . "R-GECO_local_normalization.R",
                     "--args",
                     $R_GECO_txt_direcotry,
                     $GFP_txt_directory,
                     $normalized_txt_directory,
                     $normalization_coef_file );
    &command_exercute ($normalization);
    
    my $normalized_multitiff = $normalized_txt_directory;
    $normalized_multitiff    =~ s/_txt\/$/.tif/;

    my $stack_normalized
        = join (" ", $ImageJ,
                     $bin . "txt_stack.ijm",
                     &ImageJargs( $base_dir . $normalized_txt_directory,
                                  $base_dir . $normalized_multitiff),
                     ">> $stdout_file"
               );
    &command_exercute( $stack_normalized);
    
}

print $log "Preprocessing done: " . &current_time () . "\n";
close $log;

sub current_time {
    my ($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime;
    $year += 1900; 
    $wday  = ('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[$wday];
    $mon   = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')[$mon];
    $mday  = "0" . $mday if $mday < 10;
    #my @loctime = ($wday, $mon, $mday, $year, $hour, $min, $sec);
    return join ("-", $year, $mon, $mday) . " $hour:$min:$sec";
}
