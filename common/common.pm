sub askForDownload {
	my($count, $tags) = @_;
	
	printf("[+] %i '%s' related images found\n", $count, $tags);
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
	my ($fileURL, $rating, $md5, $filter, $folder, $verbose, $statsRef) = @_;
	
	use Digest::MD5;
	use LWP::UserAgent;
	
	$fileURL =~ m/.*\/(.*\.(jpg|jpeg|png|gif))/;
	my $fileName = $1;
	
	if (-e $folder . '/' . $fileName) {
		my $file = $folder . '/' . $fileName;
		open(FILE, $file) or die "[-] Can't open '$file': $!\n";
		binmode(FILE);
		if (Digest::MD5->new->addfile(*FILE)->hexdigest eq $md5) {
			$statsRef->{c}++;
			beVerbose($verbose, "[+] File ($fileName) exists and MD5 matches\n");
			return;
		}
		else {
			$statsRef->{h}++;
			beVerbose($verbose, "[-] File ($fileName) exists but MD5 doesn't match\n");
		}
		close(FILE);
	}
	
	if ($filter) {
		if ($rating ne $filter) {
			$statsRef->{f}++;
			beVerbose($verbose, "[-] File ($fileName) doesn't match filter settings\n");
			return;
		}
	}
	
	my $ua = LWP::UserAgent->new;
	beVerbose($verbose, "[+] Downloading '$fileName'\n");
	$ua->get($fileURL, ":content_file" => $folder . '/' . $fileName);
	$statsRef->{d}++;
}

sub beVerbose {
	my ($verbose, $string) = @_;
	
	if ($verbose) {
		print $string;
	}
}

sub printStats {
	my ($statsRef) = @_;
	
	printf("\n[+] Success:\n");
	printf(" --> D: %i\n", $statsRef->{d});
	printf(" --> E: %i\n", $statsRef->{c});
	printf(" --> H: %i\n", $statsRef->{h});
	printf(" --> S: %i\n", $statsRef->{f});
}

sub printHeader {
	printf("\n.:: omnibooru.pl - MrLoom ::.\n\n");
}

sub printHelp {
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

1;