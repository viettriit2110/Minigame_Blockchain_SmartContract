// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Lotery is ReentrancyGuard, Context {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    
    struct StakingInfo {
        // uint256 amount;
        uint256 number;
        uint256 blockNumber;
        address owner;
        uint256 sideEven;
        uint256 sideOdd;
    }
    struct SumOddEven {
        uint256 sumEven;
        uint256 sumOdd;
    }
    uint256 i = 0 ;
    uint256 private _totalReward;
    // bên chẵn 
    uint256 private _sideEven;
    // bên lẻ 
    uint256 private _sideOdd;
    // tỷ lệ giải thắng 
    uint256 private _rate;
    
    uint256[] _arrBlock;
    mapping(uint256 => address[]) _arrMsg;
    mapping(uint256 => mapping (address => StakingInfo)) private _stakeMap; // blockNumber => address => stakingInfor
    mapping(uint256 => SumOddEven) private _sumOddEven;
    // tham số truyền vào 1 để deloy smart contract

    constructor(address rewardToken_, uint256 rate_) {
        token = IERC20(rewardToken_); // lấy token ở địa chỉ rewardToken
        _rate = rate_;
    }
    // tổng số phí đặt cược 
    function totalReward() external view returns (uint256) {
        return _totalReward;
    }
    // tổng số đạt cược chẵn 
    function sideEvenBalance() external view returns (uint256) {
        return _sideEven;
    }
    // tổng số đạt cược lẻ 
    function sideOddBalance() external view returns (uint256) {
        return _sideOdd;
    }
    function getSideEven(uint256 _block) external view returns (uint256){
        return _stakeMap[_block][_msgSender()].sideEven;
    }
    function getSideOdd(uint256 _block) external view returns (uint256){
        return _stakeMap[_block][_msgSender()].sideOdd;
    }
    // truyền vào  số tiền và số chẵn/lẻ
    function bet(uint256 fee_ , uint256 number_) external nonReentrant {
        require(number_ > 0, "number can not zero");
        token.safeTransferFrom(_msgSender(), address(this), fee_);
        StakingInfo storage info = _stakeMap[block.number][_msgSender()];
        info.number = number_;
        info.blockNumber = block.number;
        _arrBlock.push(block.number);
        _arrMsg[block.number].push(_msgSender());
        info.owner = _msgSender();
        if (number_ % 2 == 1) {
            info.sideOdd += fee_;
            _sideOdd += fee_;
            _sumOddEven[block.number].sumOdd += fee_;
        } else {
            info.sideEven += fee_;
            _sideEven += fee_;
            _sumOddEven[block.number].sumEven += fee_;
        }
        _totalReward += fee_;
    }
    
    // hàm trả thưởng 
    function claimReward (uint256 blockNumber_) external nonReentrant {
        require(blockNumber_ > 0, "number can not zero");
        require(blockNumber_ <= (block.number - 2), "must less than 100 block from now");
        require(_stakeMap[blockNumber_][_msgSender()].owner == _msgSender(), "must exist");
        
        StakingInfo storage info = _stakeMap[blockNumber_][_msgSender()];
        require(info.sideOdd > 0 || info.sideEven > 0,"this block you do not bet or reward paid");
        uint256 _randomNum = (uint256(blockhash(info.blockNumber)) % 999) + 1;
        if (_randomNum % 2 ==1 && info.sideOdd > 0) {
            uint256 _reward = info.sideOdd + ( info.sideOdd * _rate / 100);
            // _totalReward = _totalReward - _reward;
            token.safeTransfer(_msgSender(), _reward);
        }
        if (_randomNum % 2 ==0 && info.sideEven > 0){
            uint256 _reward = info.sideEven + ( info.sideEven * _rate / 100);
            // _totalReward = _totalReward - _reward;
            token.safeTransfer(_msgSender(), _reward);
        }
        info.sideOdd = 0;
        info.sideEven = 0;
    }
    // hàm tính thương
    function claimable (uint256 blockNumber_) public view returns(uint256,uint256) {
        require(blockNumber_ > 0, "number can not zero");
        require(blockNumber_ <= (block.number - 2), "must less than 100 block from now");
        require(_stakeMap[blockNumber_][_msgSender()].owner == _msgSender(), "must exist");
    
        StakingInfo storage info = _stakeMap[blockNumber_][_msgSender()];
        require(info.sideOdd > 0 || info.sideEven > 0,"this block you do not bet or reward paid");
        uint256 _randomNum = (uint256(blockhash(info.blockNumber)) % 999) + 1;
        if (_randomNum % 2 ==1 && info.sideOdd > 0) {
            uint256 _reward = info.sideOdd + ( info.sideOdd * _rate / 100);
            return (_randomNum,_reward);
        }
        if (_randomNum % 2 ==0 && info.sideEven > 0){
            uint256 _reward = info.sideEven + ( info.sideEven * _rate / 100);
            return (_randomNum,_reward);
        }
        
        return (_randomNum,0);
    }
    function historyBlock(uint256 blockNumber_) public view returns(uint256,uint256,uint256)
    {
        uint256 randomOE = (uint256(blockhash(blockNumber_)) % 999) + 1;    
        uint256 sumOdd = _sumOddEven[blockNumber_].sumOdd;
        uint256 sumEven = _sumOddEven[blockNumber_].sumEven;
        return (randomOE,sumEven,sumOdd);
    }
    //hàm tự động trả thưởng 
    function rewardAll() external nonReentrant 
    {
        
        for(;i <_arrBlock.length; i++)
        {
            for(uint j =0; j < _arrMsg[_arrBlock[i]].length;j++){
                StakingInfo storage info = _stakeMap[_arrBlock[i]][_arrMsg[_arrBlock[i]][j]];
                if(info.sideOdd > 0 || info.sideEven > 0){
                    uint256 _randomNum = (uint256(blockhash(info.blockNumber)) % 999) + 1;
                    if (_randomNum % 2 ==1 && info.sideOdd > 0) {
                        uint256 _reward = info.sideOdd + ( info.sideOdd * _rate / 100);
                        // _totalReward = _totalReward - _reward;
                        token.safeTransfer(_arrMsg[_arrBlock[i]][j], _reward);
                    }
                    if (_randomNum % 2 ==0 && info.sideEven > 0){
                        uint256 _reward = info.sideEven + ( info.sideEven * _rate / 100);
                        // _totalReward = _totalReward - _reward;
                        token.safeTransfer(_arrMsg[_arrBlock[i]][j], _reward);
                    }
                    info.sideOdd = 0;
                    info.sideEven = 0;
                }
            }
        }

    }
}
