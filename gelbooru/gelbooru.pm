sub initOmnibooru {
	my ($tags, $filter, $verbose) = @_;
	my $requestURL = "http://gelbooru.com/index.php?page=dapi&s=post&q=index&tags=${tags}&limit=0";
	
	use XML::Simple;
	use LWP::UserAgent;
	
	my $ua = LWP::UserAgent->new;
	my $request = $ua->get($requestURL);
	my $requestContent = $request->decoded_content;
	my $xml = XMLin($requestContent);
	
	&askForDownload($xml->{count}, $tags);
	
	my $folder = 'Gelbooru-'. $tags;
	beVerbose($verbose, "[+] Directory '$folder' created\n");
	mkdir($folder);
	
	my %stats;
	my $finish = 0;
	my $pid = 0;
	while (! $finish) {
		$requestURL = "http://gelbooru.com/index.php?page=dapi&s=post&q=index&tags=${tags}&pid=${pid}";
		$request = $ua->get($requestURL);
		$requestContent = $request->decoded_content;
		$xml = XMLin($requestContent);
		
		if (($xml->{offset} + 100) >= $xml->{count}) { $finish = 1; }
						
		for (keys %{$xml->{post}}) {
			my $dataObject = $xml->{post}->{$_};
			&processFile($dataObject->{file_url}, $dataObject->{rating}, $dataObject->{md5}, $filter, $folder, $verbose, \%stats);
		}		
		$pid++;
	}
	&printStats(\%stats);
}

1;