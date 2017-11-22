function testSinglePhotonSource(var1, var2)
    client = SinglePhotonSourceClient('128.214.235.108', 5020);
    response = client.sendReceive(struct('number', var1, 'string', var2,'whatever',1))
end

