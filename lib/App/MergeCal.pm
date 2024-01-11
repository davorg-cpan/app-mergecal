use 5.24.0;
use Feature::Compat::Class;

class App::MergeCal {

  use Encode;
  use Text::vFile::asData;
  use LWP::Simple;
  use JSON;

  field $vfile_parser :param = Text::vFile::asData->new;
  field $json_parser :param = JSON->new;
  field $title :param;
  field $output :param = '';
  field $calendars :param;

  method calendars { return $calendars }
  method title     { return $title }
  method output    { return $title }

  method run {
    my $combined = {
      type => 'VCALENDAR',
      properties => {
        'X-WR-CALNAME' => [ { value => $title } ],
      },
      objects => [],
    };

    for (@$calendars) {
      my $ics = get($_) or die "Can't get $_";
      $ics = encode_utf8($ics);
      open my $fh, '<', \$ics or die $!;
      my $data = $vfile_parser->parse( $fh );

      push @{ $combined->{objects} }, @{ $data->{objects}[0]{objects} };
    }

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
    my $conf_file = $_[0] // 'config.json';

    open my $conf_fh, '<', $conf_file or die "$conf_file: $!";
    my $json = do { local $/; <$conf_fh> };
    my $config = JSON->new->decode($json);

use Data::Printer;
p $config;

    return $class->new(%$config);
  }
}
