use strict;
use warnings;
use Scalar::Util qw(looks_like_number);

my %variables;

sub evaluate {
    my $expr = shift;
    $expr =~ s/\s+//g;  
    
    if ($expr =~ /^([a-zA-Z]+)=(.+)$/) {
        my ($var, $val) = ($1, $2);
        $variables{$var} = evaluate($val);
        return $variables{$var};
    }
    
    $expr =~ s/([a-zA-Z]+)/exists $variables{$1} ? $variables{$1} : 0/ge if %variables;
    
    my $result = eval $expr;
    if ($@) {
        print "Error in expression: $@\n";
        return 0;
    }
    return $result;
}

while (1) {
    print "> ";
    my $input = <STDIN>;
    chomp $input;
    last if $input =~ /^exit$/i;
    my $result = evaluate($input);
    print "= $result\n";
}