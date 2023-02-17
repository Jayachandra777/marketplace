pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@celo/contractkit/contracts/identity/Attestations.sol";

import "@celo/contractkit/contracts/stabletoken/StableToken.sol";

contract NFTMarketplace is ERC721, Ownable {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    struct NFT {

        string name;

        string description;

        uint256 price;

        address owner;

    }

    mapping(uint256 => NFT) private _nfts;

    Attestations private _attestations;

    StableToken private _stableToken;

    constructor(address attestationsAddress, address stableTokenAddress) ERC721("NFTMarketplace", "NFTM") {

        _attestations = Attestations(attestationsAddress);

        _stableToken = StableToken(stableTokenAddress);

    }

    function createNFT(string memory name, string memory description, uint256 price) public {

        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();

        _mint(msg.sender, tokenId);

        _nfts[tokenId] = NFT(name, description, price, msg.sender);

    }

    function purchaseNFT(uint256 tokenId) public payable {

        require(_exists(tokenId), "Token ID does not exist");

        NFT storage nft = _nfts[tokenId];

        require(msg.value == nft.price, "Incorrect payment amount");

        address payable seller = payable(nft.owner);

        _transfer(seller, msg.sender, tokenId);

        uint256 cUsdAmount = nft.price * (10 ** 18); // convert to cUSD decimal places

        _stableToken.transferFrom(msg.sender, seller, cUsdAmount);

    }

    function withdrawFunds() public {

        uint256 balance = _stableToken.balanceOf(address(this));

        _stableToken.transfer(owner(), balance);

    }

    function getNFTCount() public view returns (uint256) {

        return _tokenIds.current();

    }

    function getNFT(uint256 tokenId) public view returns (NFT memory) {

        require(_exists(tokenId), "Token ID does not exist");

        return _nfts[tokenId];

    }

}


