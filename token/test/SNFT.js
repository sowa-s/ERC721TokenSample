var snft = artifacts.require("./SNFT.sol");

contract('SNFT', function(accounts) {
    it('should valid ERC165 interface id', function(){
        return snft.deployed().then(function(instance){
            //reference from ERC165 interfaceid: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
            return instance.supportsInterface.call("0x01ffc9a7");
        }).then(function(valid){
            assert.equal(valid, true);
        });
    });

    it('should valid ERC721 interface id', function(){
        return snft.deployed().then(function(instance){
            //reference from ERC721 interfaceid: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
            return instance.supportsInterface.call("0x80ac58cd");
        }).then(function(valid){
            assert.equal(valid, true);
        });
    });

    it('should valid ERC721Metadata interface id', function(){
        return snft.deployed().then(function(instance){
            //reference from ERC721Metadata interfaceid: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
            return instance.supportsInterface.call("0x5b5e139f");
        }).then(function(valid){
            assert.equal(valid, true);
        });
    });

});
