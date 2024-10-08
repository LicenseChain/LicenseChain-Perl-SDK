# LicenseChain Perl SDK

## Overview

This SDK allows you to interact with the LicenseChain API to validate licenses using Perl.

## Installation

1. Clone the repository.
2. Make sure you have the required modules: `LWP::UserAgent` and `JSON`.

```bash
cpan install LWP::UserAgent JSON
```

3. Use the `examples/validate_license.pl` script as a guide.

## Usage

```perl
use LicenseChain;

my $lc = LicenseChain->new('your_api_key');
my $response = $lc->validate_license('your_license_key');

if (exists $response->{error}) {
    print "Error: $response->{error}
";
} else {
    print "License is valid: " . $response->{valid} . "
";
}
```

# Bugs
If the default example that wasn’t included in your software isn’t working as expected, please pop over to https://t.me/LicenseChainBot and lodge a bug report via the Support Option.

However, we don't offer support for integrating LicenseChain into your project. If you’re having trouble, you might want to have a look on Google or YouTube for tutorials on the programming language you're using to build your programme.

# Copyright License
LicenseChain is under the Elastic License 2.0.

- You’re not allowed to offer the software to third parties as a hosted or managed service, where users get access to any significant part of the software’s features or functionality.
- You mustn’t move, alter, disable, or bypass the licence key functionality in the software, and you can’t remove or hide any features protected by the licence key.
- You’re also not permitted to change, remove, or obscure any licensing, copyright, or other notices from the licensor within the software. Any use of the licensor’s trademarks must comply with relevant laws.

Cheers for sticking to these guidelines. We put a lot of effort into developing LicenseChain and don't take copyright breaches lightly.

## Support

If you have any questions or need help, feel free to open an issue or contact us at support@licensechain.app.
