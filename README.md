# NAME

Dist::Zilla::Plugin::Pinto::Add - Ship your dist to a Pinto repository

# VERSION

version 0.083

# SYNOPSIS

    # In your dist.ini
    [Pinto::Add]
    root          = http://pinto.my-host      ; at lease one root is required
    author        = YOU                       ; optional. defaults to username
    stack         = stack_name                ; optional. defaults to undef
    no_recurse    = 1                         ; optional. defaults to 0
    authenticate  = 1                         ; optional. defaults to 0
    username      = you                       ; optional. will prompt if needed
    password      = secret                    ; optional. will prompt if needed

    # Then run the release command
    dzil release

# DESCRIPTION

Dist::Zilla::Plugin::Pinto::Add is a release-stage plugin that
will add your distribution to a local or remote [Pinto](http://search.cpan.org/perldoc?Pinto) repository.

__IMPORTANT:__ You will need to install [Pinto](http://search.cpan.org/perldoc?Pinto) to make this plugin
work.  It ships separately so you can decide how you want to install
it.  I recommend installing Pinto as a stand-alone application as
described in [Pinto::Manual::Installing](http://search.cpan.org/perldoc?Pinto::Manual::Installing) and then setting the
`PINTO_HOME` environment variable.  Or you can install Pinto from
CPAN using the usual tools.  Either way, this plugin should just do
the right thing to load the necessary modules.

Before releasing, [Dist::Zilla::Plugin::Pinto::Add](http://search.cpan.org/perldoc?Dist::Zilla::Plugin::Pinto::Add) will check if the
repository is responding.  If not, you'll be prompted whether to abort
the rest of the release.

If the `authenticate` configuration option is enabled, and either the
`username` or `password` options are not configured, you will be
prompted you to enter your username and password during the
BeforeRelease phase.  Entering a blank username or password will abort
the release.

# CONFIGURATION

The following parameters can be set in the `dist.ini` file for your
distribution:

- root = REPOSITORY

    This identifies the root of the Pinto repository you want to release
    to.  If `REPOSITORY` looks like a remote URL (i.e. it starts with
    "http://") then your distribution will be shipped with
    [Pinto::Remote](http://search.cpan.org/perldoc?Pinto::Remote).  Otherwise, the `REPOSITORY` is assumed to be a
    path to a local repository directory and your distribution will be
    shipped with [Pinto](http://search.cpan.org/perldoc?Pinto).

    At least one `root` is required.  You can release to multiple
    repositories by specifying the `root` attribute multiple times.  If
    any of the repositories are not responding, we will still try to
    release to the rest of them (unless you decide to abort the release
    altogether).  If none of the repositories are responding, then the
    entire release will be aborted.  Any errors returned by one of the
    repositories will also cause the rest of the release to be aborted.

- author = NAME

    This specifies your identity as a module author.  It must be
    alphanumeric characters (no spaces) and will be forced to UPPERCASE.
    If you do not specify one, it defaults to either your PAUSE ID (if you
    have one configured in `~/.pause`) or your current username.

- stack = NAME

    This specifies which stack in the repository to put the released
    packages into.  Defaults to `undef`, which means to use whatever
    stack is currently defined as the default by the repository.

- no\_recurse = 0|1

    If true, prevents Pinto from recursively importing all the
    distributions required to satisfy the prerequisites for the
    distribution you are adding.  Default is 0.

- authenticate = 0|1

    Indicates that authentication credentials are required for
    communicating with the server (these will be prompted for, if not
    provided in the `dist.ini` file as described below).  Defaults is
    false.

- username = NAME

    Specifies the username to use for server authentication.

- password = PASS

    Specifies the password to use for server authentication.

# ENVIRONMENT VARIABLES

The following environment variables can be used to influence the
default values used for some of the parameters above.

- `PINTO_AUTHOR_ID`

    Sets the default author identity, if the `author` parameter is
    not set.

- `PINTO_USERNAME`

    Sets the default username, if the `username` parameter is not set.

# RELEASING TO MULTIPLE REPOSITORIES

You can release your distribution to multiple repositories by
specifying multiple values for the `root` attribute in your
`dist.ini` file.  In that case, the remaining attributes
(e.g. `stack`, `author`, `authenticate`) will apply to all the
repositories.

However, the recommended way to release to multiple repositories is to
have multiple `[Pinto::Add]` blocks in your `dist.ini` file.  This
allows you to set attributes for each repository independently (at the
expense of possibly having to duplicating some information).

# SUPPORT

## Perldoc

You can find documentation for this module with the perldoc command.

    perldoc Dist::Zilla::Plugin::Pinto::Add

## Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

- MetaCPAN

    A modern, open-source CPAN search engine, useful to view POD in HTML format.

    [http://metacpan.org/release/Dist-Zilla-Plugin-Pinto-Add](http://metacpan.org/release/Dist-Zilla-Plugin-Pinto-Add)

- CPAN Ratings

    The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

    [http://cpanratings.perl.org/d/Dist-Zilla-Plugin-Pinto-Add](http://cpanratings.perl.org/d/Dist-Zilla-Plugin-Pinto-Add)

- CPANTS

    The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

    [http://cpants.perl.org/dist/overview/Dist-Zilla-Plugin-Pinto-Add](http://cpants.perl.org/dist/overview/Dist-Zilla-Plugin-Pinto-Add)

- CPAN Testers

    The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

    [http://www.cpantesters.org/distro/D/Dist-Zilla-Plugin-Pinto-Add](http://www.cpantesters.org/distro/D/Dist-Zilla-Plugin-Pinto-Add)

- CPAN Testers Matrix

    The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

    [http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-Pinto-Add](http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-Pinto-Add)

- CPAN Testers Dependencies

    The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

    [http://deps.cpantesters.org/?module=Dist::Zilla::Plugin::Pinto::Add](http://deps.cpantesters.org/?module=Dist::Zilla::Plugin::Pinto::Add)

## Internet Relay Chat

You can get live help by using IRC ( Internet Relay Chat ). If you don't know what IRC is,
please read this excellent guide: [http://en.wikipedia.org/wiki/Internet\_Relay\_Chat](http://en.wikipedia.org/wiki/Internet\_Relay\_Chat). Please
be courteous and patient when talking to us, as we might be busy or sleeping! You can join
those networks/channels and get help:

- irc.perl.org

    You can connect to the server at 'irc.perl.org' and join this channel: \#pinto then talk to this person for help: thaljef.

## Bugs / Feature Requests

[https://github.com/thaljef/Dist-Zilla-Plugin-Pinto-Add/issues](https://github.com/thaljef/Dist-Zilla-Plugin-Pinto-Add/issues)

## Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

[https://github.com/thaljef/Dist-Zilla-Plugin-Pinto-Add](https://github.com/thaljef/Dist-Zilla-Plugin-Pinto-Add)

    git clone git://github.com/thaljef/Dist-Zilla-Plugin-Pinto-Add.git

# AUTHOR

Jeffrey Ryan Thalhammer <jeff@stratopan.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Jeffrey Ryan Thalhammer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
