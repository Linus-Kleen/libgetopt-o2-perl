# NAME

Getopt::O2 - Command line argument processing and automated help generation, object oriented

# SYNOPSIS

    package MyPackage;
    use parent 'Getopt::O2';

    # return a short descriptive string about the program (appears in --help)
    sub get_program_description
    {
            return 'A sample program';
    }

    # return rules about parameters
    sub get_option_rules
    {
            return shift->SUPER::get_option_rules(),
                    'length=i' => ['A numeric argument', 'default' => 33],
                    'file=s'   => ['A mandatory argument', 'required' => 1],
                    'quiet'    => ['A "flag" argument'];
    }

    # read options
    new MyPackage->getopt(\my %options, \my @values);

# DESCRIPTION

The `Getopt::O2` module implements an extended `Getopt` class which
parses the command line from `@ARGV`, recognizing and removing specified options
and their possible values.

This module adheres to the POSIX syntax for command line options, with GNU
extensions. In general, this means that options have long names instead of
single letters, and are introduced with a double dash "--". Support for
bundling of command line options, as was the case with the more traditional
single-letter approach, is provided.

`Getopt::O2` stands out for its extensive usage generation feature; anything
printed in its "usage" output is generated from the input options and saves the
users the time to write usage output by themselves.

## Methods

- _PACKAGE_->getopt(_HASHREF \[, ARRAYREF\]_)

    Processes command line options and stores their values in the hash reference
    passed as its argument. Anything not recognized as parameters or their values is
    pushed into the second (optional) `ARRAYREF`.

- _PACKAGE_->get\_option\_rules()

    Returns a list of rules of command line options. The base package provides two
    options `--help` and `--verbose` by default. The former calls `usage()`; the
    latter is an _incremental option_. See ["Writing Rules"](#writing-rules) for what your
    implementation should return.

- _PACKAGE_->get\_program()

    Returns the program name for display in usage.

- _PACKAGE_->get\_program\_description()

    Returns a short descriptive string about the program's functionality. This
    string is used as a caption of the generated program usage text and should be
    implemented by sub-modules using this module.

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
The rest are key-value-pairs that are coerced to a hash.

A single `undef` can be used to separate option categories by producing an empty
line in `usage()` output.

>     # Short variant. Define flag and its help string
>     'q|quiet' => 'Suppresses informational program output'
>
>     # Actual implementation of "--help" parameter
>     'h|help' => ['Display this help message', sub {
>         $self->usage()
>     }]
>
>     # Enumeration with allowed values
>     'o|output=?' => ['Use ARG as output format', 'values' => [qw(xml html json)]]
>
>     # One or more occurences of a value (result is ARRAYREF)
>     'i|input=s@' => 'Create result from input file ARG'
>
>     # Use callback return value as option value
>     'l|limit=i' => ['Limit amount of things', sub {
>         my ($arg, $key) = @_;
>         $arg = 100 if $arg > 100;
>         return $arg; # make sure --limit is not larger than 100
>     }]

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
- l|list=s@

    Defines an _option with a mandatory value_. The character after the `=` sign
    determines the expected value: `s` is a generic string, `i` is a numeric value
    (it uses Perl's ["looks\_like\_number" in Scalar::Util](https://metacpan.org/pod/Scalar::Util#looks_like_number)) and `?` is an enumeration. If the type
    specifier is suffixed with a `@`, the resulting value will be an ARRAYREF with
    all values.

    Enumerations must provide a `values` option which must be an ARRAYREF of valid
    values for the option. They may use the `keep_unique` option which defaults to
    being set in order to control whether the resulting list contains unique values
    or all given values.

## Contextual rules

Rules can be allowed in a given context and may change the context appropriately.

Consider the following ruleset:

>     sub get_option_rules
>     {
>         return
>             'q|quiet'     => ['Be quiet', 'context' => '-logging'],
>             'v|verbose'   => ['Be verbose', 'context' => '+logging'],
>             'l|logfile=s' => ['Log to file ARG', 'context' => 'logging']
>     }

The above example would introduce the _logging_ context; an internal state which
makes options appearing outside of that context invalid.

The `--verbose` flag would activate the context - allowing for the option `--logfile`,
which would otherwise (without the context) be considered illegal.

Contexts can be comma separated. A context of `-a,-b,+c,d` would:

- deactivate both contexts `a` and `b`
- activate context `c`
- restrict the option to the previously activated context `d`.

# TODO

# DEPENDENCIES

None special. Uses core perl libraries.

# AUTHOR

Oliver Schieche <schiecheo@cpan.org>

http://perfect-co.de/

# LICENSE AND COPYRIGHT

Copyright 2013-2019 Oliver Schieche.

This software is a free library. You can modify and/or distribute it under the
same terms as Perl itself.
