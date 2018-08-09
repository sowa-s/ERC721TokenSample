pragma solidity ^0.4.0;

import "./ERC721.sol";
import "./ERC165.sol";
import "./ERC721Metadata.sol";
import "./ERC721TokenReceiver.sol";

contract SNFT is ERC721, ERC721Metadata, ERC165 {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    ERC165 erc165;
    bytes4 interfaceIdERC165 = erc165.supportsInterface.selector;

    ERC721 erc721;
    bytes4 interfaceIdERC721 =
        erc721.balanceOf.selector ^
        erc721.ownerOf.selector ^
        erc721.transferFrom.selector ^
        erc721.approve.selector ^
        erc721.setApprovalForAll.selector ^
        erc721.getApproved.selector ^
        erc721.isApprovedForAll.selector ^
        bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)")) ^
        bytes4(keccak256("safeTransferFrom(address,address,uint256)"));

    ERC721Metadata erc721meta;
    bytes4 interfaceIdERC721Metadata =
        erc721meta.name.selector ^
        erc721meta.symbol.selector ^
        erc721meta.tokenURI.selector;

    mapping(uint256 => address) tokenOwner;
    mapping(address => uint256) tokenBalance;
    mapping(address => mapping(uint256 => address)) approveAccount; //approve_account -> (tokenId -> owner)
    mapping(address => mapping(address => bool)) operatorAccount; //owner_account -> (operator_account -> is approved)

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function addToken(address _to, uint256 _tokenId) external onlyOwner {
        tokenBalance[_to]++;
        tokenOwner[_tokenId] = _to;
    }

    //ERC721 methods
    function balanceOf(address _owner) external view returns (uint256){
        return tokenBalance[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address){
        return tokenOwner[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable {
        this.transferFrom(_from, _to, _tokenId);

        if(!isContract(_to)){
            return;
        }

        bytes4 interfaceId = ERC721TokenReceiver(_to).onERC721Received(_from, _to, _tokenId, data);
        if(interfaceId != bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))){
            revert();
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
        this.safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(tokenOwner[_tokenId] == _from);

        if(approveAccount[msg.sender][_tokenId] == _from){
            _transfer(_from, _to, _tokenId);
            delete approveAccount[msg.sender][_tokenId];
            return;
        }

        if(msg.sender == _from){
            _transfer(_from, _to, _tokenId);
            return;
        }

        if(operatorAccount[_from][msg.sender]){
            _transfer(_from, _to, _tokenId);
        }
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(msg.sender == tokenOwner[_tokenId]);
        approveAccount[_approved][_tokenId] = msg.sender;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        require(msg.sender != _operator);
        operatorAccount[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return approveAccount[msg.sender][_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return operatorAccount[_owner][_operator];
    }

    //ERC721Metadata methods
    function name() external view returns (string _name) {
        return "SNFT";
    }

    function symbol() external view returns (string _symbol) {
        return "S";
    }

    function tokenURI(uint256 _tokenId) external view returns (string) {
        return "";
    }

    //ERC165 methods
    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return (interfaceIdERC165 == interfaceID) || (interfaceIdERC721 == interfaceID) || (interfaceIdERC721Metadata == interfaceID);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        tokenBalance[_to]++;
        tokenBalance[_from]--;
        tokenOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    //ref: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/AddressUtils.sol
    function isContract(address _account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_account) }
        return size > 0;
    }
}
