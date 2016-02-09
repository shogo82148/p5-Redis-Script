package Redis::Script;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Digest::SHA qw(sha1_hex);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        use_evalsha => 1,
        %args,
    }, $class;

    return $self;
}

sub eval {
    my ($self, $redis, $keys, $args) = @_;
    if ($self->{use_evalsha}) {
        my $sha = $self->sha1;
        my $ret = eval { $redis->evalsha($sha, scalar(@$keys), @$keys, @$args) };
        if (my $err = $@) {
            die $err if $err !~ /\[evalsha\] NOSCRIPT No matching script/i;
        } else {
            return (wantarray && ref $ret eq 'ARRAY') ? @$ret : $ret;
        }
    }

    my $ret = $redis->eval($self->{script}, scalar(@$keys), @$keys, @$args);

    return (wantarray && ref $ret eq 'ARRAY') ? @$ret : $ret;
}

sub exists {
    my ($self, $redis) = @_;
    return $redis->script_exists($self->sha1)->[0];
}

sub load {
    my ($self, $redis) = @_;
    my $sha = $self->sha1;
    my $redis_sha = $redis->script_load($self->{script});
    if (lc $sha ne lc $redis_sha) {
        die "SHA is unmatch (expected $sha but redis returns $redis_sha)";
    }
    return $sha;
}

sub sha1 {
    my $self = shift;
    return $self->{sha} ||= sha1_hex($self->{script});
}

1;
__END__

=encoding utf-8

=head1 NAME

Redis::Script - It's new $module

=head1 SYNOPSIS

    use Redis::Script;

=head1 DESCRIPTION

Redis::Script is ...

=head1 LICENSE

Copyright (C) Ichinose Shogo.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ichinose Shogo E<lt>shogo82148@gmail.comE<gt>

=cut

