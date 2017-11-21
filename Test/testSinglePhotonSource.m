function testSinglePhotonSource()
    client = SinglePhotonSourceClient('127.0.0.1', 9898);
    response = client.sendReceive(struct('number', 1, 'string', 'abcd'))
end

