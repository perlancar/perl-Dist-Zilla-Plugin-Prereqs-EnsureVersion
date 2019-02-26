package Dist::Zilla::Plugin::Prereqs::SetMinimumVersion::FromPmVersions;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Moose;
with 'Dist::Zilla::Role::PrereqSource';

use namespace::autoclean;

use PMVersions::Util qw(version_from_pmversions);

sub register_prereqs {
    my ($self) = @_;

    my $prereqs_hash = $self->zilla->prereqs->as_string_hash;

    for my $phase (sort keys %$prereqs_hash) {
        next if $phase =~ /^x_/;
        for my $rel (sort keys %{$prereqs_hash->{$phase}}) {
            next if $rel =~ /^x_/;
            my $versions = $prereqs_hash->{$phase}{$rel};
            for my $mod (sort keys %$versions) {
                my $ver = $versions->{$mod};
                my $minver = version_from_pmversions($mod);
                next unless defined $minver;
                if (version->parse($minver) > version->parse($ver)) {
                    $self->log_debug([
                        "Setting minimum version of prerequisite %s (%s %s) to %s",
                        $mod, $phase, $rel, $minver]);
                    $self->zilla->register_prereqs({phase => $phase, type => $rel}, $mod, $minver);
                }
            }
        }
    }

    {};
}

__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: Set minimum version of prereqs from pmversions.ini

=for Pod::Coverage .+

=head1 SYNOPSIS

In F<~/pmversions.ini>:

 Log::ger=0.019
 File::Write::Rotate=0.28

In F<dist.ini>:

 [Prereqs::SetMinimumVersion::FromPmVersions]


=head1 DESCRIPTION

This plugin is the counterpart of
L<[Prereqs::EnsureVersion]|Dist::Zilla::Plugin::Prereqs::EnsureVersion>.
[Prereqs::EnsureVersion] checks prereqs and aborts the build when a prereq
specifies version less than specified in F<pmversions.ini>.
[Prereqs::SetMinimumVersion::FromPmVersions] on the other hand, sets a prereq's
minimum version to that specified in F<pmversions.ini>.


=head1 ENVIRONMENT

=head2 PMVERSIONS_PATH

String. Set location of F<pmversions.ini> instead of the default
C<~/pmversions.ini>. Example: C</etc/minver.conf>. Note that this is actually
observed by in L<PMVersions::Util>.


=head1 SEE ALSO

L<Dist::Zilla::Plugin::Prereqs::EnsureVersion>
