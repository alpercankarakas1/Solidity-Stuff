// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
// It shows how to setup multiple execution paths for handling a response.
pragma solidity 0.8.19;
 
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
 
/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
 
contract VRFCekilis is VRFConsumerBaseV2Plus {
 
    // Your subscription ID.
    uint256 s_subscriptionId;
 
    // Sepolia coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf/v2-5/supported-networks
    address vrfCoordinatorV2Plus = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
 
    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2-5/supported-networks
    bytes32 keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
 
    uint32 callbackGasLimit = 300000;
 
    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;
 
    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
    uint32 numWords = 1;
 
    address[] public katilimcilar;
    address public kazanan;
    bool public yarismaBitti;
    uint256 public randomNumber;
 
 
    constructor(uint256 subscriptionId) VRFConsumerBaseV2Plus(vrfCoordinatorV2Plus)  {
        s_vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinatorV2Plus);
        s_subscriptionId = subscriptionId;
    }
 
    function requestRandomWords() internal {
      uint256 _requestId = s_vrfCoordinator.requestRandomWords(VRFV2PlusClient.RandomWordsRequest({
            keyHash: keyHash,
            subId: s_subscriptionId,
            requestConfirmations: requestConfirmations,
            callbackGasLimit: callbackGasLimit,
            numWords: numWords,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
          })
        );
    }
 
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        randomNumber = randomWords[0];
        kazanan = katilimcilar[randomWords[0] % katilimcilar.length];
        yarismaBitti = true;
    }
 
    function yarismayaKatil() external payable {
        require(!yarismaBitti, "Yarisma bitti");
        require(msg.value == 0.003 ether, "0.003 ether gondermelisiniz");
        katilimcilar.push(msg.sender);
    }
 
    function kazananiBelirle() external onlyOwner {
        requestRandomWords();   
    }
 
    function paraCek() external {
        require(msg.sender == kazanan);
        (bool sonuc, ) = kazanan.call{value: address(this).balance}("");
        require(sonuc);
    }
 
    function katilimciSayisi() public view returns (uint256){
        return katilimcilar.length;
    }
 
    receive() external payable {}
    fallback() external payable {}
}