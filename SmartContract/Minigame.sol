// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Minigame{
    
    Hocvien[] public arrHocvien;
    
    struct Hocvien{
        string _ID;
        address _VI;
    }
    
    event SM_ban_data(address _vi,string _id);

    function DangKy(string memory _id) public{
        Hocvien memory hocvienMoi = Hocvien(_id,msg.sender);
        arrHocvien.push(hocvienMoi);
        emit SM_ban_data(msg.sender,_id);
    }
}