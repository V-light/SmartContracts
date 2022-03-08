// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract Sign{

    function verify(address _signer, string memory _message, bytes memory _sig) public pure returns(bool){
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessage(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }
    function getMessageHash(string memory _message) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_message));
    }
    function getEthSignedMessage(bytes32 _messageHash) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_messageHash));
    } 

    function recover(bytes32 ethSignedMessage , bytes memory _sig) public pure returns(address){
        (bytes32 r, bytes32 s, uint8 v) = split(_sig);
        return ecrecover(ethSignedMessage, v, r, s);
    }
    function split(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
         
            r := mload(add(sig, 32))
           
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        
    }

}