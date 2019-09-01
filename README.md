# NAME

Getopt::O2 - Command line argument processing and automated help generation, object oriented

# SYNOPSIS

    package MyPackage;
    use base 'Getopt::O2';

    # return a short descriptive string about the program (appears in --help)
    sub getProgramDescription
        {
            'A sample program'
        }

    # return rules about parameters
    sub getOptionRules
        {
            shift->SUPER::getOptionRules(),
                'length=i' => ['A numeric argument', 'default' => 33],
                'file=s'   => ['A text argument'],
                'quiet'    => ['A "flag" argument'];
        }

    # read options
    new MyPackage->getopt(\%options);

# DESCRIPTION

The `Getopt::O2` module implements an extended `Getopt` class which
parses the command line from @ARGV, recognizing and removing specified options
and their possible values.

This function adheres to the POSIX syntax for command line options, with GNU
extensions. In general, this means that options have long names instead of
single letters, and are introduced with a double dash "--". Support for
bundling of command line options, as was the case with the more traditional
single-letter approach, is provided.

## Methods

- _PACKAGE_->getopt(_HASHREF_)

    Processes command line options and stores their values in the hash reference
    passed as its argument.

- _PACKAGE_->getOptionRules()

    Returns a list of rules of command line options. The base package provides two
    options `--help` and `--verbose` by default. The former calls `usage()`; the
    latter is an _incremental option_. See ["Writing Rules"](#writing-rules) for what your
    implementation should return.

- _PACKAGE_->getProgramDescription()

    Returns a short descriptive string about the program's functionality. This
    string is used as a caption of the generated program usage text.

- _PACKAGE_->usage(_CODE \[, MESSAGE \[, LIST \] \]_)

    Display program usage summary and exit with status `CODE`. Without any further
    arguments it will show the program's description text. If given, `MESSAGE` will
    be treated as an `sprintf()`-like formatter string followed by its arguments
    and prefixed with "Error: ".

- _PACKAGE_->error(_MESSAGE \[, LIST \]_)

    This method is called internally when processing or validation of options
    failed and does nothing but passing its arguments to `usage()` (along with an
    exit code of `1`). Override this method if you require other methods of error
    handling.

## Writing Rules

Command line options are processed using rules returned the `getOptionsRules()`
implementation. Rules are expressed much like with [Getopt::Long](https://metacpan.org/pod/Getopt::Long). A rule
expression is followed by the rule's help string and possible options.

The options must be represented as either a string (used as help string) or an
ARRAYREF. The first element of the latter is used as the options' help string.
Its second element can be a CODEREF which is called when the option was seen.
The rest are key-value-pairs that are coerced to a hash. A single `undef` can
be used to separate option categories (used in `usage()`).

>     # Short variant. Define flag and its help string
>     'q|quiet' => 'Suppresses informational program output'
>
>     # Actual implementation of "--help" parameter
>     'h|help' => ['Display this help message', sub {
>         $self->usage()
>     }]
>
>     # Use callback return value as option value
>     'l|limit=i' => ['Limit amount of things', sub {
>         my ($arg, $key) = @_;
>         $arg = 100 if $arg > 100;
>         return $arg; # make sure --limit is not larger than 100
>     }]
>
>     # Enumeration with allowed values
>     'o|output=?' => ['Use ARG as output format', 'values' => [qw(xml html json)]]

## Rule syntax

- !w|warnings

    Defines a _negatable option_. The value of it will be a "boolean" in the
    resulting options hash reference depending on whether `--warnings` or
    `--no-warnings` was seen on the command line. There's no short negatable
    option.

- v|verbose+

    Defines an _incremental option_. Depending on how often it's seen on the
    command line, the option's value will increase in the resulting hashref.

- q|quiet

    Defines a _flag option_. The flag will be set in the resulting hashref if this
    option was seen on the command line.

- f|filename=s

    Defines an _option with a mandatory value_. The character after the `=` sign
    determines the expected value: `s` is a generic string, `i` is a numeric value
    (it uses Perl's [looks\_like\_number](https://metacpan.org/pod/looks_like_number)) and `?` is an enumeration. If the type
    specifier is suffixed with a `@`, the resulting value will be an ARRAYREF with
    all values.

    Enumerations must provide a `values` option which must be an ARRAYREF of valid
    values for the option. They may use the `keep_unique` option which defaults to
    being set in order to control whether the resulting list contains unique values
    or all given values.

# TODO

# DEPENDENCIES

None special. Uses core perl libraries.

# AUTHOR

Oliver Schieche <schiecheo@cpan.org>

http://perfect-co.de/

$Id: O2.pm 888 2019-09-01 20:36:34Z schieche $

# LICENSE AND COPYRIGHT

Copyright 2013-2019 Oliver Schieche.

This software is a free library. You can modify and/or distribute it under the
same terms as Perl itself.