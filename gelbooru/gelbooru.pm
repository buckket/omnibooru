{
	package Gelbooru;
	@ISA = qw(Omnibooru::Common);

	sub new {
		my $type = shift;
		my %params = @_;
		my $self = {};
	
		$self->{'tags'} = $params{'tags'};
		$self->{'filter'} = $params{'filter'};
		$self->{'verbose'} = $params{'verbose'};
	
		bless $self, $type;
	}

	sub process{
		my $self = shift;
	
		my $requestURL = "http://gelbooru.com/index.php?page=dapi&s=post&q=index&tags=$self->{'tags'}&limit=0";
		print $requestURL;
	
		use XML::Simple;
		use LWP::UserAgent;
	
		my $ua = LWP::UserAgent->new;
		my $request = $ua->get($requestURL);
		my $requestContent = $request->decoded_content;
		my $xml = XMLin($requestContent);
	
		$self->askForDownload('count' => $xml->{count});
	
		my $folder = 'Gelbooru-'. $self->{'tags'};
		$self->beVerbose('string' => "[+] Directory '$folder' created\n");
		mkdir($folder);
	
		my %stats;
		my $finish = 0;
		my $pid = 0;
		while (! $finish) {
			$requestURL = "http://gelbooru.com/index.php?page=dapi&s=post&q=index&tags=$self->{'tags'}&pid=${pid}";
			$request = $ua->get($requestURL);
			$requestContent = $request->decoded_content;
			$xml = XMLin($requestContent);
		
			if (($xml->{offset} + 100) >= $xml->{count}) { $finish = 1; }
						
			for (keys %{$xml->{post}}) {
				my $dataObject = $xml->{post}->{$_};
				$self->processFile('fileURL' => $dataObject->{file_url}, 'rating' => $dataObject->{rating}, 'md5' => $dataObject->{md5}, 'folder' => $folder, 'statsRef' => \%stats);
			}		
			$pid++;
		}
		$self->printStats('statsRef' => \%stats);
	}
}
1;
