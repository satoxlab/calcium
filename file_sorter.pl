#!/usr/bin/perl

use strict;
use warnings;

use File::Copy;

sub sorting_files {
    my ($dir) = @_;
    $dir .= "/" if $dir !~ m/\/$/;
    
    my $R_GECO_dir = $dir;
    $R_GECO_dir    =~ s/_(f\d{4})_t(\d{4}-\d{4})/_${1}_w0001_t${2}/;
    my $GFP_dir = $dir;
    $GFP_dir    =~ s/_(f\d{4})_t(\d{4}-\d{4})/_${1}_w0000_t${2}/;
    
    mkdir ($R_GECO_dir);
    mkdir ($GFP_dir);
    
    opendir (my $indir, $dir);
    my @files = grep{/.tif$/} readdir ($indir);
    closedir ($indir);
    
    for (0..$#files){
        if ($files[$_] =~ m/w0000/){
            move ($dir . $files[$_], $GFP_dir . $files[$_]);
        }
        elsif ($files[$_] =~ m/w0001/){
            move ($dir . $files[$_], $R_GECO_dir . $files[$_]);
        }
        else{
            die "$files[$_]: unspecified distination ";
        }
    }

    return ($R_GECO_dir, $GFP_dir);
}

1;
