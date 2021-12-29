# Smart Contract VietLot

1. Chức năng game sẽ giống với vietlott
2. Viết smartcontract gồm các chức năng ( Quay số, trả thưởng, đặt cược, lịch sử quay thưởng )
3. Số random từ 01 tới 55, gồm 6 chữ số, mỗi lần gọi hàm quay thưởng phải random 6 lần mỗi lần là 1 số

### Người dùng : Người dùng sẽ gọi lệnh Bet và sau đó gọi lệnh trả thưởng claimReward
### Ví dụ cần view kì quay , danh sách địa chỉ đặt cược, danh sách địa chỉ người trúng ... thì gọi hàm tương ứng. 
* IERC20 public immutable token: khai báo 1 token không thể thay đổi. 
    
### Gọi hàm theo thứ tự: 
    + Bước 1: Đặt Cược
        - Hàm gọi: bet(numberBet_)
    
**Từ bước 2-> bước 4 bắt buộc làm theo các bước không sẽ báo lỗi**

    + Bước 2: Quay Thưởng và return mảng 6 số 
        - Hàm gọi: dice(turn) <quay thật> Hoặc setNumberReward(turn) <quay fix cứng>  
    + Bước 3: Kiểm tra các địa chỉ trúng thưởng
        - Hàm gọi: listAddressWin(turn) 
    + Bước 4: Trả thưởng
        - Hàm gọi:  + nếu muốn trả thưởng tại turn cho tất cả người chơi gọi hàm : claimReward(turn_)
                    + nếu muốn người chơi tự nhận thưởng gọi hàm : claimRewardPerson(turn_)
                    + chỉ được gọi 1 trong 2 hàm. Mỗi turn sẽ chỉ được gọi 1 kiểu trả thưởng. 
- Token: 
    + **address: 0x361DF0978d19084311e59c3109EA77B6cff1ee06**

- Contract VietLot: (Factory Token, Staking,Voting, ...)
    + **address: 0x72c41e5475A9F6eBcf5075f8F7471c7AB0fc44B1**
   
* **hàm bet(uint256[6] numberBet_):**
    - Chức Năng: Mua vé Viet lot
    - Truyền : gồm 1 array có 6 số theo thứ tự tăng dần.
    - return: chuyển token vào ví contract  và đặt cược 

* **hàm dice(turn_):**
    - Chức Năng: quay random 6 số trúng thưởng
    - Truyền : kỳ quay muốn quay thưởng
    - return: mảng 6 số đã quay

* **hàm setNumberReward(turn_):**
    - Chức Năng: tạo giải thưởng fix cứng [1,2,3,4,5,6] để test
    - Truyền: turn muốn fix cứng giải.
    - return : mảng 6 số 

* **hàm listAddressWin(turn_):**
    - Chức Năng: kiểm tra các đỉa chỉ trúng thưởng tại turn_
    - Truyền : kỳ quay 
    - return: không (kết quả lưu vào biến để gọi)

* **hàm claimReward(numberTurn_):**
    - Chức Năng: trả thưởng 
    - Truyền : số kì muốn trả thưởng 
    - return : trả thưởng có các address thắng, nếu đang trong kì đặt cược sẽ không gọi được hàm.

* **hàm getCheckReward(numberTurn_):**
    - Chức Năng: return 3 số lần lượt
        + kiểm tra turn truyền vào đã quay thưởng hay chưa 
        + return block number hiện tại 
        + return block sẽ được quay tại turn đó 
    - Truyền : số kì muốn check
    - return : 3 số lần lượt là (true hoặc false) và block hiện tại và số block tương lai sẽ quay.

* **hàm getNumberReward(turn_):**
    - Chức Năng: trả về kết quả quay tại turn đó 
    - Truyền : turn muốn xem
    - return : mảng 6 số kết quả

* **hàm getTurnOfAddress():**
    - Chức Năng: trả về các turn mà địa chỉ gọi đến
    - Truyền : không
    - return : mảng turn địa chỉ gọi đến. 
* **hàm getTurn():**
    - Chức Năng: Lấy ra đang ở kỳ quay bao nhiêu
    - Truyền : không.
    - return: 2 số lần lượt là "số turn hiện tại, số tiền giải thưởng" 

* **hàm getHistoryBet(uint256 turn_):**
    - Chức Năng: Lấy ra lịch sử đặt cược tại "turn_" của người gọi
    - Truyền: kỳ quay muốn lấy (turn_)
    - return : mảng 2 chiều có kích thước [n][6] (với n là số lần mua của người gọi trong turn đó)

* **hàm getAddressBet (turn_):**
    - Chức Năng: Trả về 1 mảng tất cả địa chỉ đặt cược trong turn truyền vào
    - Truyền : số turn
    - return : 1 mảng chứa tất cả địa chỉ 

![alt text](https://github.com/devNgoLong/SmartContractGameAneed/blob/DevTri/contracts/VietLot/hinh1.png)
![alt text](https://github.com/devNgoLong/SmartContractGameAneed/blob/DevTri/contracts/VietLot/hinh2.png)