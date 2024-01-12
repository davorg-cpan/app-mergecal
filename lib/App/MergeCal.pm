use 5.24.0;
use Feature::Compat::Class;

class App::MergeCal {

  our $VERSION = '0.0.1';

  use Encode 'encode_utf8';
  use Text::vFile::asData;
  use LWP::Simple;
  use JSON;

  field $vfile_parser :param = Text::vFile::asData->new;
  field $json_parser :param = JSON->new;
  field $title :param;
  field $output :param = '';
  field $calendars :param;
  field $objects;

  method calendars { return $calendars }
  method title     { return $title }
  method output    { return $title }

  method run {
    $self->gather;
    $self->render;
  }

  method gather {
    for (@$calendars) {
      my $ics = get($_) or die "Can't get $_";
      $ics = encode_utf8($ics);
      open my $fh, '<', \$ics or die $!;
      my $data = $vfile_parser->parse( $fh );

      push @$objects, @{ $data->{objects}[0]{objects} };
    }
  }

  method render {
    my $combined = {
      type => 'VCALENDAR',
      properties => {
        'X-WR-CALNAME' => [ { value => $title } ],
      },
      objects => $objects,
    };

    my $out_fh;
    if ($output) {
      open $out_fh, '>', $output
        or die "Cannot open output file [$output]: $!\n";
      select $out_fh;
    }

    say "$_\r" for Text::vFile::asData->generate_lines($combined);
  }

  sub new_from_json {
    my $class = shift;
    my ($json) = @_;

    my $data = JSON->new->decode($json);

    return $class->new(%$data);
  }

  sub new_from_json_file {
    my $class = shift;
    my $conf_file = $_[0] // 'config.json';

    open my $conf_fh, '<', $conf_file or die "$conf_file: $!";
    my $json = do { local $/; <$conf_fh> };

    return $class->new_from_json($json);
  }
}

1;
