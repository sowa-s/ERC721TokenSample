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

    it('should create token by owner', function(){
        var token;
        return snft.deployed().then(function(instance){
            token = instance;
            return token.addToken(accounts[0], 1234);
        }).then(function(){
            return token.ownerOf.call(1234);
        }).then(function(addr){
            assert.equal(addr, accounts[0]);
        });
    });

    it('should transfer own token', function(){
        var token;
        return snft.deployed().then(function(instance){
            token = instance;
            return token.addToken(accounts[0], 1234);
        }).then(function(){
            return token.transferFrom(accounts[0], accounts[1], 1234);
        }).then(function(){
            return token.ownerOf.call(1234);
        }).then(function(addr){
            assert.equal(addr, accounts[1]);
        });
    });

    it('should approve user', function(){
        var token;
        return snft.deployed().then(function(instance){
            token = instance;
            return token.addToken(accounts[0], 1234);
        }).then(function(){
            return token.approve(accounts[1], 1234);
        }).then(function(){
            return token.transferFrom(accounts[0], accounts[2], 1234, {from: accounts[1]});
        }).then(function(){
            return token.ownerOf.call(1234);
        }).then(function(addr){
            assert.equal(addr, accounts[2]);
            return token.getApproved.call(1234);
        }).then(function(addr){
            assert.equal(addr, "0x0000000000000000000000000000000000000000");
        });
    });

    it('should add operator user', function(){
        var token;
        return snft.deployed().then(function(instance){
            token = instance;
            return token.addToken(accounts[0], 1234);
        }).then(function(){
            return token.setApprovalForAll(accounts[1], true);
        }).then(function(){
            return token.transferFrom(accounts[0], accounts[2], 1234, {from: accounts[1]});
        }).then(function(){
            return token.ownerOf.call(1234);
        }).then(function(addr){
            assert.equal(addr, accounts[2]);
            return token.getApproved.call(1234);
        });
    });


    //TODO: safeTransferFromのテストを追加
    //TODO: Failケースのテストを追加
});
