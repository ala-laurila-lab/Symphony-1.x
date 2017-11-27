function testSinglePhotonSource()
    % client = SinglePhotonSourceClient('128.214.235.108', 5020);
    client = SinglePhotonSourceClient('127.0.0.1', 9898);
    a = struct();
    a.preTime = 100;
    a.stimTime = 100;
    a.tailTime = 200;
    a.sourceType = 'SPS';
    a.photonRate = 5;
    a.action = 0;
    response = client.sendReceive(a, 0)
end

