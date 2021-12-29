// SPDX-License-Identifier: MIT

pragma solidity >=0.7.8;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract VietLot is ReentrancyGuard, Context {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    
    uint256 money = 10**18;
    uint256 genesisBlock;
    uint256 turn = 1;
    address manager;
    uint check30 = 1;

    constructor(address rewardToken_,uint256 money_) {
        token = IERC20(rewardToken_); // lấy token ở địa chỉ rewardToken
        manager = _msgSender();
        genesisBlock = block.number;
        money = money * money_;
    }

    struct InfoBet{
        bool checkInOut;
        bool checkTraThuong; // check trả thưởng 
        uint256[] blockBet; 
        uint256[6][] numberBet;
    }

    struct StakingInfo{
        bool checkReward; // check trả thưởng 
        bool checkSpinBonus; // check quay thưởng 
        bool checkKiemTraPerson; 
        bool checkTraTungNguoi;
        uint256 moneyReward;
        uint256[6] numberReward;
        address[] addressBet;
        address[] addressWinBet;
        address[] addressWin5;
        address[] addressWin4;
        mapping (address => InfoBet) infoAddressBet;
    }

    mapping (uint256 => StakingInfo) _stakeMap;
    mapping (address => uint256[] ) _addressMap;

    function bet(uint256[6] memory numberBet_) external nonReentrant {
        turn = uint256((block.number - genesisBlock)/50) +1 ;
        uint256 fee_ = 100 * 10 ** 18;
        token.safeTransferFrom(_msgSender(), address(this), fee_);
        if ((_addressMap[_msgSender()].length==0)||(_addressMap[_msgSender()].length >0 && _addressMap[_msgSender()][_addressMap[_msgSender()].length-1] != turn))
            _addressMap[_msgSender()].push(turn);
        StakingInfo storage _info = _stakeMap[turn];
        if(_info.infoAddressBet[_msgSender()].checkInOut == false){
            _info.addressBet.push(_msgSender());
            _info.infoAddressBet[_msgSender()].checkInOut  = true;
        }
        InfoBet storage _infoBet =_info.infoAddressBet[_msgSender()];
        _infoBet.blockBet.push(block.number);
        _infoBet.numberBet.push(numberBet_);
    }
    
    function getTurnOfAddress() public view returns(uint256[] memory){
        return _addressMap[_msgSender()];
    }
    function getTurn() public view returns(uint256,uint256){
        uint256 gturn = uint256((block.number - genesisBlock)/50) +1;
        return (gturn,(check30* money));
    }

    function getHistoryBet(uint256 turn_) public view returns(uint256[6][] memory ){
        return _stakeMap[turn_].infoAddressBet[_msgSender()].numberBet;
    }

    function getNumberReward(uint256 turn_) public view returns(uint256[6] memory ,uint256){
        return (_stakeMap[turn_].numberReward,turn_ * 50 + genesisBlock +1);
    }
     function getAddressBet(uint256 turn_) public view returns(address[] memory ){
        return _stakeMap[turn_].addressBet;
    }
    // turn đã quay chưa, block hien tại, còn bao nhiêu block nữa thì quay 
    function getCheckReward(uint256 turn_) public view returns(bool ,uint256,uint256){
        return (_stakeMap[turn_].checkSpinBonus ,block.number,  turn_ * 50 + genesisBlock +1);
    }

    function getGenesis() public view returns(uint256,uint256){
        return (genesisBlock,block.number);
    }

    function setNumberReward(uint256 turn_) external returns(uint256[6] memory)  {
        uint256 tinhTurn_ = uint256((block.number - genesisBlock)/50) +1 ;
        require(tinhTurn_ > turn_ ,"chua sang turn moi de quay");
        StakingInfo storage _info = _stakeMap[turn_];
        if (_info.checkSpinBonus == true)
            revert("da quay so");
        for(uint i=1; i <= 6; i++ ){
            _info.numberReward[i-1] = i;
        }
        _info.checkSpinBonus = true;
        return _info.numberReward;
    }

    // random số thưởng tại turn 
    function dice(uint256 numberTurn_) external returns(uint256[6] memory) {
        uint256 tinhTurn_ = uint256((block.number - genesisBlock)/50) +1 ;
        require(tinhTurn_ > numberTurn_ ,"chua sang turn moi de quay");
        uint256 numberRan = block.number;
        StakingInfo storage _info = _stakeMap[numberTurn_];
        if (_info.checkSpinBonus == true)
            revert("da quay so");
        _info.checkSpinBonus = true;
        _info.moneyReward = check30 * money;
        uint256[6] memory ab;
        for(uint i=0; i < 6; i++ ){
            uint256 a1 = (uint256(blockhash(numberRan-i-1)) % 55) + 1;
            ab[i] = a1;
        }
        for (uint i = 0; i < 5; i++) {
            for (uint j = i + 1; j < 6; j++)
            if (ab[j] < ab[i]){
                uint temp = ab[i];
                ab[i] = ab[j];
                ab[j] = temp;
            }
        }
        for(uint i=0; i < 6; i++ ){
            _info.numberReward[i] = ab[i];
        }
        return _info.numberReward;
    }

    // list address trúng thưởng tại numberTurn
    function listAddressWin(uint256 numberTurn_) public {
        // uint256 numberRan = numberTurn_ * 100 + genesisBlock;
        StakingInfo storage _info = _stakeMap[numberTurn_];
        require(_info.checkSpinBonus == true,"chua quay thuong, goi ham dice");
        delete _info.addressWinBet;
        for(uint i=0; i < _info.addressBet.length; i++)
        {
            uint256[6][] memory numberBet_ = _info.infoAddressBet[_info.addressBet[i]].numberBet;
            for(uint j=0;j < numberBet_.length; j++){
                uint check_ ;
                uint256[56] memory check__;
                for(uint kt=0; kt < 6; kt++ ){
                    check__[numberBet_[j][kt]] = 1;
                }
                for(uint kt=0; kt < 6; kt++ ){
                    if(check__[_info.numberReward[kt]] == 1)
                        check_ ++;
                }
                if (check_ == 6){
                    _info.addressWinBet.push(_info.addressBet[i]);
                }
                else if(check_ == 5)
                    _info.addressWin5.push(_info.addressBet[i]);
                else if(check_ == 4)
                    _info.addressWin4.push(_info.addressBet[i]);
                for(uint kt=0; kt < 6; kt++ ){
                    check__[numberBet_[j][kt]] = 0;
                }
            }
        }
        _info.checkKiemTraPerson = true;
    }
    
    // danh sach trung thuong tai turn _
    function getListAddressWinTurn(uint256 turn_) public view returns(address[] memory ){
        return _stakeMap[turn_].addressWinBet;
    }
    function getListAddressWin5(uint256 turn_) public view returns(address[] memory ){
        return _stakeMap[turn_].addressWin5;
    }
    function getListAddressWin4(uint256 turn_) public view returns(address[] memory ){
        return _stakeMap[turn_].addressWin4;
    }
    function claimReward (uint256 numberTurn_) external nonReentrant {
        uint256 tinhTurn_ = uint256((block.number - genesisBlock)/50) +1 ;
        require(tinhTurn_ > numberTurn_ ,"chua sang turn moi de quay");
        StakingInfo storage _info = _stakeMap[numberTurn_];
        require(_info.checkReward == false , "da tra thuong");
        require(_info.checkKiemTraPerson = true, "chua goi ham listAddressWin");
        require(_info.checkTraTungNguoi == false,"turn nay da co nguoi tu nhan thuong hay goi ham claimRewardPerson ");
        if (_info.addressWinBet.length == 0 && _info.addressWin5.length == 0 && _info.addressWin4.length == 0 )
        {
            if (check30 < 30 )
                check30 ++;
        }
        else{
            _info.moneyReward = check30 * money;
            if (_info.addressWinBet.length != 0)
                for(uint i=0; i< _info.addressWinBet.length;i++)
                {
                    token.safeTransfer(_info.addressWinBet[i],_info.moneyReward/_info.addressWinBet.length);
                }
            if (_info.addressWin5.length != 0)
                for(uint i=0; i< _info.addressWin5.length;i++)
                {
                    token.safeTransfer(_info.addressWin5[i],3000 * 10**18);
                }
            if (_info.addressWin4.length != 0)
                for(uint i=0; i< _info.addressWin4.length;i++)
                {
                    token.safeTransfer(_info.addressWin4[i],1000 * 10**18);
                }
            check30 = 1;
        }
        _info.checkReward = true;
    }
    function claimRewardPerson (uint256 numberTurn_) external nonReentrant {
        uint256 tinhTurn_ = uint256((block.number - genesisBlock)/50) +1 ;
        require(tinhTurn_ > numberTurn_ ,"chua sang turn moi de quay");
        StakingInfo storage _info = _stakeMap[numberTurn_];
        require(_info.checkReward == false , "da tra thuong");
        require(_info.checkKiemTraPerson = true, "chua goi ham listAddressWin");
        require(_info.infoAddressBet[_msgSender()].checkTraThuong == false,"da tra thuong");
        if (_info.addressWinBet.length == 0 && _info.addressWin5.length == 0 && _info.addressWin4.length == 0 )
        {
            if (check30 < 30 )
                check30 ++;
        }
        else{
            _info.moneyReward = check30 * money;
            uint256 check_;
            if (_info.addressWinBet.length != 0)
                for(uint i=0; i< _info.addressWinBet.length;i++)
                {
                    if(_info.addressWinBet[i] ==_msgSender() )
                        check_ +=_info.moneyReward/_info.addressWinBet.length;
                }
            if (_info.addressWin5.length != 0)
                for(uint i=0; i< _info.addressWin5.length;i++)
                {
                    if(_info.addressWin5[i] ==_msgSender() )
                        check_ += 3000* 10**18;
                }
            if (_info.addressWin4.length != 0)
                for(uint i=0; i< _info.addressWin4.length;i++)
                {
                    if(_info.addressWin4[i] ==_msgSender() )
                        check_ +=1000* 10**18;
                }
            token.safeTransfer(_msgSender(),check_ );
            check30 = 1;
        }
        _info.checkTraTungNguoi = true;
    }
}
