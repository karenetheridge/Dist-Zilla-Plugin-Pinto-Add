#!perl

use strict;
use warnings;

use Test::More;
use Test::DZil;
use Test::Exception;

use File::Temp;
use Class::Load;
use Dist::Zilla::Tester;
use Dist::Zilla::Plugin::Pinto::Add;

no warnings qw(redefine once);

#------------------------------------------------------------------------------
# Much of this test was deduced from:
#
#  https://metacpan.org/source/RJBS/Dist-Zilla-4.300016/t/plugins/uploadtocpan.t
#
# But it isn't clear how much of the D::Z testing API is actually stable and
# public.  So I wouldn't be surpised if these tests start failing with newer
# D::Z.
#------------------------------------------------------------------------------

my $has_pinto_tester = Class::Load::try_load_class('Pinto::Tester');
plan skip_all => 'Pinto::Tester required' if not $has_pinto_tester;

my $has_pinto = Class::Load::try_load_class('Pinto');
plan skip_all => 'Pinto required' if not $has_pinto;

#------------------------------------------------------------------------------

sub build_tzil {

  my $dist_ini = simple_ini('GatherDir', 'ModuleBuild', @_);

  return Builder->from_config(
    { dist_root => 'corpus/dist/DZT' },
    { add_files => {'source/dist.ini' => $dist_ini} } );
}

#---------------------------------------------------------------------
# read author from $ENV;

{

  local $ENV{USER} = 'DUMMY';

  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => {root => $root, pauserc => ''}] );
  $tzil->release;

  $t->registration_ok("DUMMY/DZT-Sample-0.001/DZT::Sample~0.001/");
}

#---------------------------------------------------------------------
# read author from pauserc

{
  my $pauserc = File::Temp->new;
  print {$pauserc} "user PAUSEID\n";
  my $pause_file = $pauserc->filename;

  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => {root => $root, pauserc => $pause_file}] );
  $tzil->release;

  $t->registration_ok("PAUSEID/DZT-Sample-0.001/DZT::Sample~0.001/");
}

#---------------------------------------------------------------------
# read author from dist.ini

{
  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => {root => $root, author => 'AUTHORID'}] );
  $tzil->release;

  $t->registration_ok("AUTHORID/DZT-Sample-0.001/DZT::Sample~0.001/");
}

#---------------------------------------------------------------------
# prompt for username/password

{
  my ($username, $password);

  # Intercept release() method and record some attributes
  local *Dist::Zilla::Plugin::Pinto::Add::release = sub {
    ($username, $password) = ($_[0]->username, $_[0]->password);
  };

  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => { root => $root,
                                             authenticate => 1}] );

  $tzil->chrome->set_response_for('Pinto username: ', 'myusername');
  $tzil->chrome->set_response_for('Pinto password: ', 'mypassword');

  $tzil->release;

  is $password, 'mypassword', 'got password from prompt';
  is $username, 'myusername', 'got username from prompt';
}

#---------------------------------------------------------------------
# username/password from dist.ini

{
  my ($username, $password);

  # Intercept release() method and record some attributes
  local *Dist::Zilla::Plugin::Pinto::Add::release = sub {
    ($username, $password) = ($_[0]->username, $_[0]->password);
  };

  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => { root => $root,
                                             username => 'myusername',
                                             password => 'mypassword',
                                             authenticate => 1}] );

  $tzil->release;
  is $password, 'mypassword', 'got password from dist.ini';
  is $username, 'myusername', 'got username from dist.ini';
}

#---------------------------------------------------------------------
# demand password

{
  my $t     = Pinto::Tester->new;
  my $root  = $t->pinto->root->stringify;
  my $tzil  = build_tzil( ['Pinto::Add' => { root => $root,
                                             username => 'myusername',
                                             authenticate => 1}] );

  throws_ok { $tzil->release }
    qr/need to supply a password/, "demanded password";
}


#---------------------------------------------------------------------
# multiple repositories

{
  my $t1     = Pinto::Tester->new;
  my $root1  = $t1->pinto->root->stringify;

  my $t2     = Pinto::Tester->new;
  my $root2  = $t2->pinto->root->stringify;

  my $tzil  = build_tzil( ['Pinto::Add' => { root => [$root1, $root2],
                                             author => 'AUTHORID' }] );

  $tzil->release;

  $t1->registration_ok("AUTHORID/DZT-Sample-0.001/DZT::Sample~0.001/");
  $t2->registration_ok("AUTHORID/DZT-Sample-0.001/DZT::Sample~0.001/");
}

#---------------------------------------------------------------------
# one of the repositories is locked -- abort release

{
  my $t1     = Pinto::Tester->new;
  my $root1  = $t1->pinto->root->stringify;

  my $t2     = Pinto::Tester->new;
  my $root2  = $t2->pinto->root->stringify;
  $t2->pinto->repos->lock_exclusive;

  my $tzil  = build_tzil( ['Pinto::Add' => { root => [$root1, $root2],
                                             author => 'AUTHORID' }] );

  local $Pinto::Locker::LOCKFILE_TIMEOUT = 5;
  my $prompt = "repository at $root2 is not available.  Abort the rest of the release?";

  $tzil->chrome->set_response_for($prompt, 'Y');
  throws_ok { $tzil->release } qr/Aborting/;

  $t1->repository_clean_ok;
  $t2->repository_clean_ok;
}

#---------------------------------------------------------------------
# one of the repositories is locked -- partial release

{
  my $t1     = Pinto::Tester->new;
  my $root1  = $t1->pinto->root->stringify;

  my $t2     = Pinto::Tester->new;
  my $root2  = $t2->pinto->root->stringify;
  $t2->pinto->repos->lock_exclusive;

  my $tzil  = build_tzil( ['Pinto::Add' => { root => [$root1, $root2],
                                             author => 'AUTHORID' }] );

  local $Pinto::Locker::LOCKFILE_TIMEOUT = 5;
  my $prompt = "repository at $root2 is not available.  Abort the rest of the release?";

  $tzil->chrome->set_response_for($prompt, 'N');
  lives_ok { $tzil->release };

  $t1->registration_ok("AUTHORID/DZT-Sample-0.001/DZT::Sample~0.001/");
  $t2->repository_clean_ok;
}


#---------------------------------------------------------------------
done_testing;

__END__

    'FakeRelease',
    [ UploadToCPAN => { %safety_first } ],
  );
 
  # Pretend user just hits Enter at the prompts:
  set_responses($tzil, '', '');
 
  like( exception { $tzil->release },
        qr/You need to supply a username/,
        "release without credentials fails");
 
  my $msgs = $tzil->log_messages;
 
  ok(grep({ /You need to supply a username/} @$msgs), "insist on username");
  ok(!grep({ /Uploading.*DZT-Sample/ } @$msgs), "no upload without credentials");
  ok(
    !grep({ /fake release happen/i } @$msgs),
    "no release without credentials"
  );
}
 
#---------------------------------------------------------------------
# No config at all, but enter username:
{
  my $tzil = build_tzil(
    'FakeRelease',
    [ UploadToCPAN => { %safety_first } ],
  );
 
  # Pretend user just hits Enter at the password prompt:
  set_responses($tzil, 'user', '');
 
  like( exception { $tzil->release },
        qr/You need to supply a password/,
        "release without password fails");
 
  my $msgs = $tzil->log_messages;
 
  ok(grep({ /You need to supply a password/} @$msgs), "insist on password");
  ok(!grep({ /Uploading.*DZT-Sample/ } @$msgs), "no upload without password");
  ok(
    !grep({ /fake release happen/i } @$msgs),
    "no release without password"
  );
}
#------------------------------------------------------------------------------



my $tzil = Dist::Zilla::Tester->from_config(
  { dist_root => 'corpus/dist/FooBar' },
  { add_files => { 'source/dist.ini' => $dist_ini } },
);

$tzil->build;
$tzil->release;

$tinto->registration_ok('ME/FooBar-1.0/Foo~1.0');
$tinto->registration_ok('ME/FooBar-1.0/Bar~1.2');

#------------------------------------------------------------------------------
done_testing;
