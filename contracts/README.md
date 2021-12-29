# Smart Contract Lotery

* IERC20 public immutable token: khai báo 1 token không thể thay đổi. 
* Thuộc tính:
    - _totalReward : tổng đặt cược
    - _sideEven    : tổng đặt bên chẵn 
    - _sideOdd     : tổng đặt bên lẻ 
    - _fee         : phí đặt cược 
    - _rate        : tỷ lệ thắng 
    - _stakeMap(mapping) :  blockNumber => address => stakingInfor
    -  StakingInfo : 
        + number : số chẵn hoặc lẻ
        + blockNumber : block đặt cược 
        + owner    : Dịa chỉ 
* contructor : truyền (address) chứa token,(_fee) phí cược, (_rate) tỷ lệ thắng 

* hàm getSideEven(_block): 
    - Chức Năng: lấy tổng cược bên CHẴN của ví (msg.sender) đang gọi đến block. 
    - Truyền : số block
    - return: Tổng cược bên CHẴN của ví đang gọi.

* hàm getSideEven(_block): 
    - Chức Năng: lấy tổng cược bên LẺ của ví (msg.sender) đang gọi đến block. 
    - Truyền : số block
    - return: Tổng cược bên LẺ của ví đang gọi.

* hàm totalReward():
    - Chức năng: trả kết quả tổng đặt cược cả chẵn và lẻ trên tất cả block đặt cược
    - Truyền: không
    - return: trả kết quả tổng đặt cược cả chẵn và lẻ trên tất cả block đặt cược

* hàm sideEvenBlance():
    - Chức năng: trả kết quả tổng đặt cược bên CHẴN trên tất cả block đặt cược
    - Truyền: không
    - return: trả kết quả tổng đặt cược bên CHẴN trên tất cả block đặt cược

* hàm sideOddBalance(): 
    - Chức năng: trả kết quả tổng đặt cược bên LẺ trên tất cả block đặt cược
    - Truyền: không
    - return: trả kết quả tổng đặt cược bên LẺ trên tất cả block đặt cược

* Hàm bet: (fee_,number_) 
    - Chức Năng: Đặt cược
    - Truyền : 2 tham số lần lượt là tiền đặt cược, số chẵn/lẻ
    - return : không có.

* hàm claimReward(blockNumber_): 
    - Chức Năng: hàm trả thưởng tại block truyền vào của địa chỉ ví đang gọi
    - Truyền : block cần trả kết quả  
    - return : chỉ trả thưởng. 

* hàm claimable (blockNumber_): 
    - Chức Năng: hàm tính thưởng tại block truyền vào của địa chỉ ví đang gọi
    - Truyền : block cần trả kết quả  
    - return : trả về 2 số kết quả (số chẵn/lẻ, Số tiền thưởng) tại block đó .

* hàm historyBlock(blockNumber_):
    - Chức năng: Trả về 3 kết quả lần lượt "kết quả Chẵn/Lẻ, Tổng Chẵn đặt, Tổng Lẻ đặt" trên block đó.
    - Truyền: block cần trả kết quả.
    - return: 3 số lần lượt "kết quả Chẵn/Lẻ, Tổng Chẵn đặt, Tổng Lẻ đặt" trên block đó
