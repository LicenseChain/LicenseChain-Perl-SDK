use 5.010;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'LicenseChain::SDK',
    VERSION_FROM        => 'lib/LicenseChain/SDK.pm',
    ABSTRACT_FROM       => 'lib/LicenseChain/SDK.pm',
    AUTHOR              => 'LicenseChain Team <support@licensechain.app>',
    LICENSE             => 'Elastic-2.0',
    MIN_PERL_VERSION    => '5.010',
    PREREQ_PM => {
        'Carp'                    => 0,
        'Data::Dumper'            => 0,
        'Encode'                  => 0,
        'Exporter'                => 0,
        'HTTP::Tiny'              => 0,
        'JSON'                    => 2.90,
        'LWP::UserAgent'          => 6.00,
        'MIME::Base64'            => 0,
        'Time::HiRes'             => 0,
        'URI'                     => 1.50,
        'URI::Escape'             => 0,
        'Digest::SHA'             => 5.80,
        'Digest::HMAC'            => 1.03,
        'Try::Tiny'               => 0.30,
        'Scalar::Util'            => 0,
        'List::Util'              => 0,
        'POSIX'                   => 0,
        'Time::Piece'             => 0,
        'Time::Seconds'           => 0,
    },
    TEST_REQUIRES => {
        'Test::More'              => 0.98,
        'Test::Exception'         => 0.40,
        'Test::MockObject'        => 1.20180705,
        'Test::Warnings'          => 0.026,
    },
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker'     => 6.48,
    },
    BUILD_REQUIRES => {
        'ExtUtils::MakeMaker'     => 6.48,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources => {
            repository => {
                type => 'git',
                url  => 'https://github.com/LicenseChain/LicenseChain-Perl-SDK.git',
                web  => 'https://github.com/LicenseChain/LicenseChain-Perl-SDK',
            },
            homepage => 'https://docs.licensechain.app/sdks/perl',
            bugtracker => {
                web => 'https://github.com/LicenseChain/LicenseChain-Perl-SDK/issues',
            },
            license => 'https://raw.githubusercontent.com/LicenseChain/LicenseChain-Perl-SDK/main/LICENSE',
        },
        prereqs => {
            runtime => {
                requires => {
                    perl => '5.010',
                },
            },
        },
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'LicenseChain-SDK-*' },
);
