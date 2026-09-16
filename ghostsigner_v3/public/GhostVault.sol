pragma solidity ^0.8.19;

contract GhostVault {
    address public immutable OWNER;
    uint256 public immutable COLD_PX;
    uint256 public immutable COLD_PY;
    uint256 public nonce;

    event Withdrawn(address indexed to, uint256 nonce);

    constructor(address owner_, uint256 startNonce, uint256 px, uint256 py) {
        OWNER = owner_; nonce = startNonce; COLD_PX = px; COLD_PY = py;
    }

    function authHash() public view returns (bytes32) {
        uint256 unlock = uint256(keccak256(abi.encodePacked("GHOST", nonce)));
        return keccak256(
            abi.encodePacked("GHOSTVAULT_WITHDRAW", address(this), nonce, unlock)
        );
    }

    function _ethSigned(bytes32 h) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", h));
    }

    function withdraw(uint8 v, bytes32 r, bytes32 s) external {
        address signer = ecrecover(_ethSigned(authHash()), v, r, s);
        require(signer != address(0) && signer == OWNER, "bad/again");
        nonce += 1;
        emit Withdrawn(msg.sender, nonce - 1);
    }
}
