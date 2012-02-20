{
package Omnibooru::Common;


	sub askForDownload {
		my $self = shift;
		my %params = @_;
		
		if ($params{'count'} == 0) { die("[-] Empty result\n"); };
	
		printf("[+] %i '%s' related images found\n", $params{'count'}, $self->{'tags'});
		printf("[?] Start download? y/n: ");
		chomp(my $answer = <STDIN>);
		if ($answer eq "y") {
			printf("\n")
		} elsif ($answer eq "n") {
			die "[-] Aborted\n";
		} else {
			die "[-] y/n, stupid!\n";
		}
	}

	sub processFile {
		my $self = shift;
		my %params = @_;
	
		my $filter = $self->{'filter'};
		my $verbose = $self->{'verbose'};
	
	
		use Digest::MD5;
		use LWP::UserAgent;
	
		$params{'fileURL'} =~ m/.*\/(.*\.(jpg|jpeg|png|gif))/;
		my $fileName = $1;
	
		if (-e $params{'folder'} . '/' . $fileName) {
			my $file = $params{'folder'} . '/' . $fileName;
			open(FILE, $file) or die "[-] Can't open '$file': $!\n";
			binmode(FILE);
			if (Digest::MD5->new->addfile(*FILE)->hexdigest eq $params{'md5'}) {
				$params{'statsRef'}->{c}++;
				$self->beVerbose('string' => "[+] File ($fileName) exists and MD5 matches\n");
				return;
			}
			else {
				$params{'statsRef'}->{h}++;
				$self->beVerbose('string' => "[-] File ($fileName) exists but MD5 doesn't match\n");
			}
			close(FILE);
		}
	
		if ($filter) {
			if ($params{'rating'} ne $filter) {
				$params{'statsRef'}->{f}++;
				$self->beVerbose('string' => "[-] File ($fileName) doesn't match filter settings\n");
				return;
			}
		}
	
		my $ua = LWP::UserAgent->new;
		$self->beVerbose('string' => "[+] Downloading '$fileName'\n");
		$ua->get($params{'fileURL'}, ":content_file" => $params{'folder'} . '/' . $fileName);
		$params{'statsRef'}->{d}++;
	}

	sub beVerbose {
		my $self = shift;
		my %params = @_;
	
		if ($self->{'verbose'}) {
			print $params{'string'};
		}
	}

	sub printStats {
		my $self = shift;
		my %params = @_;

		printf("\n[+] Success:\n");
		printf(" --> D: %i\n", $params{'statsRef'}->{d});
		printf(" --> E: %i\n", $params{'statsRef'}->{c});
		printf(" --> H: %i\n", $params{'statsRef'}->{h});
		printf(" --> S: %i\n", $params{'statsRef'}->{f});
	}

	sub printHeader {
		my $self = shift;
	
		printf("\n.:: omnibooru.pl - MrLoom ::.\n\n");
	}

	sub printHelp {
		my $self = shift;
	
		printf("Usage: omnibooru.pl [option] software tags\n\n");
		printf("Options:\n");
		printf(" -s -> Safe content only\n");
		printf(" -e -> Explicit content only\n");
		printf(" -v -> Verbose\n\n");
		printf("Software:\n");
		printf(" 1 or gelbooru for Gelbooru\n");
		printf(" 2 or danbooru for Danbooru (NOT YET)\n\n");
		printf("Tags:\n");
		printf(" eg. kinoshita_hideyoshi\n\n");
		printf("Example:\n");
		printf(" ./omnibooru -v -e 1 kinoshita_hideyoshi\n");
	}
}
1;
