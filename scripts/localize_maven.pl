#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp;

sub localize_maven {
    my ($file) = @_;

    die "File does not exist: $file\n" unless -f $file;
    die "Not a Gradle file (must end in .gradle or .gradle.kts): $file\n"
        unless $file =~ /\.(gradle|gradle\.kts)$/;

    my $content = read_file($file);
    my $modified_content = $content;

    $modified_content =~ s{
        (maven\s*\{)               # Start of maven block
        ((?:[^{}]*|\{[^{}]*\})*?)  # Content of the block (non-greedy)
        (\})                       # Closing brace
    }{
        # Check if the block contains plugins.gradle.org
        my $block = $1 . $2 . $3;
        $block =~ /plugins\.gradle\.org/ ? $block : "mavenLocal()"
    }gexs;

    if ($modified_content ne $content) {
        # Write the modified content back to the file
        open(my $out, '>', $file) or die "Can't open $file: $!";
        print $out $modified_content;
        close $out;

        print "Processed file: $file\n";
    }
}

localize_maven($ARGV[0]) if @ARGV;

1;
