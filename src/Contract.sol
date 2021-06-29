/**
 *Submitted for verification at Etherscan.io on 2021-01-26
 https://etherscan.io/address/0xe714485b00e1062c1dfef1aee64ad6c8b85987f3#code
 */

pragma solidity 0.4.25;

contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
            return 0;
        }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

contract GenePoolInterface {
    function isGenePool() public pure returns (bool);

    function breed(
        uint256[2] mother,
        uint256[2] father,
        uint256 seed
    ) public view returns (uint256[2]);

    function randomDNA(uint256 seed) public pure returns (uint256[2]);
}

contract Usernames {
    mapping(address => bytes32) public addressToUser;
    mapping(bytes32 => address) public userToAddress;
    event UserNamed(address indexed user, bytes32 indexed username);

    function claimUsername(bytes32 _username) external {
        require(userToAddress[_username] == address(0));
        if (addressToUser[msg.sender] != bytes32(0)) {
            userToAddress[addressToUser[msg.sender]] = address(0);
        }
        addressToUser[msg.sender] = _username;
        userToAddress[_username] = msg.sender;
        emit UserNamed(msg.sender, _username);
    }
}

interface ERC721TokenReceiver {
    function onERC721Received(
        address _from,
        uint256 _tokenId,
        bytes data
    ) external returns (bytes4);
}

contract Genetic {
    uint8 public constant R = 5;

    function breed(
        uint256[2] mother,
        uint256[2] father,
        uint256 seed
    ) internal view returns (uint256[2] memOffset) {
        assembly {
            memOffset := mload(0x40)
            mstore(0x40, add(memOffset, 64))
            mstore(0x0, seed)
            mstore(0x20, timestamp)
            let hash := keccak256(0, 64)
            function shiftR(value, offset) -> result {
                result := div(value, exp(2, offset))
            }
            function processSide(fatherSrc, motherSrc, rngSrc) -> result {
                {
                    {
                        if eq(and(rngSrc, 0x1), 0) {
                            let temp := fatherSrc
                            fatherSrc := motherSrc
                            motherSrc := temp
                        }
                        rngSrc := shiftR(rngSrc, 1)
                    }
                    let mask := 0
                    let cap := 0
                    let crossoverLen := and(rngSrc, 0x7f)
                    rngSrc := shiftR(rngSrc, 7)
                    let crossoverPos := crossoverLen
                    let crossoverPosLeading1 := 1
                    for {

                    } and(lt(crossoverPos, 256), lt(cap, 4)) {
                        crossoverLen := and(rngSrc, 0x7f)
                        rngSrc := shiftR(rngSrc, 7)
                        crossoverPos := add(crossoverPos, crossoverLen)
                        cap := add(cap, 1)
                    } {
                        mask := sub(crossoverPosLeading1, 1)
                        crossoverPosLeading1 := mul(1, exp(2, crossoverPos))
                        mask := xor(mask, sub(crossoverPosLeading1, 1))
                        result := or(result, and(mask, fatherSrc))
                        let temp := fatherSrc
                        fatherSrc := motherSrc
                        motherSrc := temp
                    }
                    mask := not(sub(crossoverPosLeading1, 1))
                    result := or(result, and(mask, fatherSrc))
                    mstore(0x0, rngSrc)
                    mstore(
                        0x20,
                        0x434f4c4c454354205045504553204f4e2043525950544f50455045532e494f21
                    )
                    let mutations := and(
                        and(
                            and(keccak256(0, 32), keccak256(1, 33)),
                            and(keccak256(2, 34), keccak256(3, 35))
                        ),
                        keccak256(0, 36)
                    )
                    result := xor(result, mutations)
                }
            }
            {
                let relativeFatherSideLoc := mul(and(hash, 0x1), 0x20)
                let relativeMotherSideLoc := mul(and(hash, 0x2), 0x10)
                hash := div(hash, 4)
                mstore(
                    memOffset,
                    processSide(
                        mload(add(father, relativeFatherSideLoc)),
                        mload(add(mother, relativeMotherSideLoc)),
                        hash
                    )
                )
                relativeFatherSideLoc := xor(relativeFatherSideLoc, 0x20)
                relativeMotherSideLoc := xor(relativeMotherSideLoc, 0x20)
                mstore(0x0, seed)
                mstore(0x20, not(timestamp))
                hash := keccak256(0, 64)
                mstore(
                    add(memOffset, 0x20),
                    processSide(
                        mload(add(father, relativeFatherSideLoc)),
                        mload(add(mother, relativeMotherSideLoc)),
                        hash
                    )
                )
            }
        }
    }

    function randomDNA(uint256 seed)
        internal
        pure
        returns (uint256[2] memOffset)
    {
        assembly {
            memOffset := mload(0x40)
            mstore(0x40, add(memOffset, 64))
            mstore(0x0, seed)
            mstore(
                0x20,
                0x434f4c4c454354205045504553204f4e2043525950544f50455045532e494f21
            )
            {
                let hash := keccak256(0, 64)
                mstore(memOffset, hash)
                hash := keccak256(0, 32)
                mstore(add(memOffset, 32), hash)
            }
        }
    }
}

contract ERC721 {
    function implementsERC721() public pure returns (bool);

    function totalSupply() public view returns (uint256 total);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function ownerOf(uint256 _tokenId) public view returns (address owner);

    function approve(address _to, uint256 _tokenId) public;

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public returns (bool);

    function transfer(address _to, uint256 _tokenId) public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
}

contract Affiliate is Ownable {
    mapping(address => bool) public canSetAffiliate;
    mapping(address => address) public userToAffiliate;

    function setAffiliateSetter(address _setter) public onlyOwner {
        canSetAffiliate[_setter] = true;
    }

    function setAffiliate(address _user, address _affiliate) public {
        require(canSetAffiliate[msg.sender]);
        if (userToAffiliate[_user] == address(0)) {
            userToAffiliate[_user] = _affiliate;
        }
    }
}

contract Beneficiary is Ownable {
    address public beneficiary;

    constructor() public {
        beneficiary = msg.sender;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }
}

contract Haltable is Ownable {
    uint256 public haltTime;
    bool public halted;
    uint256 public haltDuration;
    uint256 public maxHaltDuration = 8 weeks;
    modifier stopWhenHalted {
        require(!halted);
        _;
    }
    modifier onlyWhenHalted {
        require(halted);
        _;
    }

    function halt(uint256 _duration) public onlyOwner {
        require(haltTime == 0);
        require(_duration <= maxHaltDuration);
        haltDuration = _duration;
        halted = true;
        haltTime = now;
    }

    function unhalt() public {
        require(now > haltTime + haltDuration || msg.sender == owner);
        halted = false;
    }
}

contract PepeInterface is ERC721 {
    function cozyTime(
        uint256 _mother,
        uint256 _father,
        address _pepeReceiver
    ) public returns (bool);

    function getCozyAgain(uint256 _pepeId) public view returns (uint64);
}

contract AuctionBase is Beneficiary {
    mapping(uint256 => PepeAuction) public auctions;
    PepeInterface public pepeContract;
    Affiliate public affiliateContract;
    uint256 public fee = 37500;
    uint256 public constant FEE_DIVIDER = 1000000;
    struct PepeAuction {
        address seller;
        uint256 pepeId;
        uint64 auctionBegin;
        uint64 auctionEnd;
        uint256 beginPrice;
        uint256 endPrice;
    }
    event AuctionWon(
        uint256 indexed pepe,
        address indexed winner,
        address indexed seller
    );
    event AuctionStarted(uint256 indexed pepe, address indexed seller);
    event AuctionFinalized(uint256 indexed pepe, address indexed seller);

    constructor(address _pepeContract, address _affiliateContract) public {
        pepeContract = PepeInterface(_pepeContract);
        affiliateContract = Affiliate(_affiliateContract);
    }

    function savePepe(uint256 _pepeId) external {
        require(auctions[_pepeId].auctionEnd < now);
        require(pepeContract.transfer(auctions[_pepeId].seller, _pepeId));
        emit AuctionFinalized(_pepeId, auctions[_pepeId].seller);
        delete auctions[_pepeId];
    }

    function changeFee(uint256 _fee) external onlyOwner {
        require(_fee < fee);
        fee = _fee;
    }

    function startAuction(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration
    ) public {
        require(pepeContract.transferFrom(msg.sender, address(this), _pepeId));
        require(now > auctions[_pepeId].auctionEnd);
        PepeAuction memory auction;
        auction.seller = msg.sender;
        auction.pepeId = _pepeId;
        auction.auctionBegin = uint64(now);
        auction.auctionEnd = uint64(now) + _duration;
        require(auction.auctionEnd > auction.auctionBegin);
        auction.beginPrice = _beginPrice;
        auction.endPrice = _endPrice;
        auctions[_pepeId] = auction;
        emit AuctionStarted(_pepeId, msg.sender);
    }

    function startAuctionDirect(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration,
        address _seller
    ) public {
        require(msg.sender == address(pepeContract));
        require(now > auctions[_pepeId].auctionEnd);
        PepeAuction memory auction;
        auction.seller = _seller;
        auction.pepeId = _pepeId;
        auction.auctionBegin = uint64(now);
        auction.auctionEnd = uint64(now) + _duration;
        require(auction.auctionEnd > auction.auctionBegin);
        auction.beginPrice = _beginPrice;
        auction.endPrice = _endPrice;
        auctions[_pepeId] = auction;
        emit AuctionStarted(_pepeId, _seller);
    }

    function calculateBid(uint256 _pepeId)
        public
        view
        returns (uint256 currentBid)
    {
        PepeAuction storage auction = auctions[_pepeId];
        uint256 timePassed = now - auctions[_pepeId].auctionBegin;
        if (now >= auction.auctionEnd) {
            return auction.endPrice;
        } else {
            int256 priceDifference =
                int256(auction.endPrice) - int256(auction.beginPrice);
            int256 duration =
                int256(auction.auctionEnd) - int256(auction.auctionBegin);
            int256 priceChange =
                (priceDifference * int256(timePassed)) / duration;
            int256 price = int256(auction.beginPrice) + priceChange;
            return uint256(price);
        }
    }

    function getFees() public {
        beneficiary.transfer(address(this).balance);
    }
}

contract CozyTimeAuction is AuctionBase {
    constructor(address _pepeContract, address _affiliateContract)
        public
        AuctionBase(_pepeContract, _affiliateContract)
    {}

    function startAuction(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration
    ) public {
        require(pepeContract.getCozyAgain(_pepeId) <= now);
        super.startAuction(_pepeId, _beginPrice, _endPrice, _duration);
    }

    function startAuctionDirect(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration,
        address _seller
    ) public {
        require(pepeContract.getCozyAgain(_pepeId) <= now);
        super.startAuctionDirect(
            _pepeId,
            _beginPrice,
            _endPrice,
            _duration,
            _seller
        );
    }

    function buyCozy(
        uint256 _pepeId,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _pepeReceiver
    ) public payable {
        require(address(pepeContract) == msg.sender);
        PepeAuction storage auction = auctions[_pepeId];
        require(now < auction.auctionEnd);
        uint256 price = calculateBid(_pepeId);
        require(msg.value >= price);
        uint256 totalFee = (price * fee) / FEE_DIVIDER;
        auction.seller.transfer(price - totalFee);
        address affiliate = affiliateContract.userToAffiliate(_pepeReceiver);
        if (affiliate != address(0) && affiliate.send(totalFee / 2)) {}
        if (_candidateAsFather) {
            if (
                !pepeContract.cozyTime(
                    auction.pepeId,
                    _cozyCandidate,
                    _pepeReceiver
                )
            ) {
                revert();
            }
        } else {
            if (
                !pepeContract.cozyTime(
                    _cozyCandidate,
                    auction.pepeId,
                    _pepeReceiver
                )
            ) {
                revert();
            }
        }
        if (!pepeContract.transfer(auction.seller, _pepeId)) {
            revert();
        }
        if (msg.value > price) {
            _pepeReceiver.transfer(msg.value - price);
        }
        emit AuctionWon(_pepeId, _pepeReceiver, auction.seller);
        delete auctions[_pepeId];
    }

    function buyCozyAffiliated(
        uint256 _pepeId,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _pepeReceiver,
        address _affiliate
    ) public payable {
        affiliateContract.setAffiliate(_pepeReceiver, _affiliate);
        buyCozy(_pepeId, _cozyCandidate, _candidateAsFather, _pepeReceiver);
    }
}

contract RebornCozyTimeAuction is AuctionBase {
    constructor(address _pepeContract, address _affiliateContract)
        public
        AuctionBase(_pepeContract, _affiliateContract)
    {}

    function startAuction(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration
    ) public {
        require(pepeContract.getCozyAgain(_pepeId) <= now);
        super.startAuction(_pepeId, _beginPrice, _endPrice, _duration);
    }

    function startAuctionDirect(
        uint256 _pepeId,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration,
        address _seller
    ) public {
        require(pepeContract.getCozyAgain(_pepeId) <= now);
        super.startAuctionDirect(
            _pepeId,
            _beginPrice,
            _endPrice,
            _duration,
            _seller
        );
    }

    function buyCozy(
        uint256 _pepeId,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _pepeReceiver
    ) public payable {
        require(address(pepeContract) == msg.sender);
        PepeAuction storage auction = auctions[_pepeId];
        require(now < auction.auctionEnd);
        uint256 price = calculateBid(_pepeId);
        require(msg.value >= price);
        uint256 totalFee = (price * fee) / FEE_DIVIDER;
        auction.seller.transfer(price - totalFee);
        address affiliate = affiliateContract.userToAffiliate(_pepeReceiver);
        if (affiliate != address(0) && affiliate.send(totalFee / 2)) {}
        if (_candidateAsFather) {
            if (
                !pepeContract.cozyTime(
                    auction.pepeId,
                    _cozyCandidate,
                    _pepeReceiver
                )
            ) {
                revert();
            }
        } else {
            if (
                !pepeContract.cozyTime(
                    _cozyCandidate,
                    auction.pepeId,
                    _pepeReceiver
                )
            ) {
                revert();
            }
        }
        if (!pepeContract.transfer(auction.seller, _pepeId)) {
            revert();
        }
        if (msg.value > price) {
            _pepeReceiver.transfer(msg.value - price);
        }
        emit AuctionWon(_pepeId, _pepeReceiver, auction.seller);
        delete auctions[_pepeId];
    }

    function buyCozyAffiliated(
        uint256 _pepeId,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _pepeReceiver,
        address _affiliate
    ) public payable {
        affiliateContract.setAffiliate(_pepeReceiver, _affiliate);
        buyCozy(_pepeId, _cozyCandidate, _candidateAsFather, _pepeReceiver);
    }
}

contract PepeBase is Genetic, Ownable, Usernames, Haltable {
    uint32[15] public cozyCoolDowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(15 minutes),
        uint32(30 minutes),
        uint32(45 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];
    struct Pepe {
        address master;
        uint256[2] genotype;
        uint64 canCozyAgain;
        uint64 generation;
        uint64 father;
        uint64 mother;
        uint8 coolDownIndex;
    }
    mapping(uint256 => bytes32) public pepeNames;
    Pepe[] public pepes;
    bool public implementsERC721 = true;
    string public constant name = "Crypto Pepe";
    string public constant symbol = "CPEP";
    mapping(address => uint256[]) private wallets;
    mapping(address => uint256) public balances;
    mapping(uint256 => address) public approved;
    mapping(address => mapping(address => bool)) public approvedForAll;
    uint256 public zeroGenPepes;
    uint256 public constant MAX_PREMINE = 100;
    uint256 public constant MAX_ZERO_GEN_PEPES = 1100;
    address public miner;
    modifier onlyPepeMaster(uint256 _pepeId) {
        require(pepes[_pepeId].master == msg.sender);
        _;
    }
    modifier onlyAllowed(uint256 _tokenId) {
        require(
            msg.sender == pepes[_tokenId].master ||
                msg.sender == approved[_tokenId] ||
                approvedForAll[pepes[_tokenId].master][msg.sender]
        );
        _;
    }
    event PepeBorn(
        uint256 indexed mother,
        uint256 indexed father,
        uint256 indexed pepeId
    );
    event PepeNamed(uint256 indexed pepeId);

    constructor() public {
        Pepe memory pepe0 =
            Pepe({
                master: 0x0,
                genotype: [uint256(0), uint256(0)],
                canCozyAgain: 0,
                father: 0,
                mother: 0,
                generation: 0,
                coolDownIndex: 0
            });
        pepes.push(pepe0);
    }

    function _newPepe(
        uint256[2] _genoType,
        uint64 _mother,
        uint64 _father,
        uint64 _generation,
        address _master
    ) internal returns (uint256 pepeId) {
        uint8 tempCoolDownIndex;
        tempCoolDownIndex = uint8(_generation / 2);
        if (_generation > 28) {
            tempCoolDownIndex = 14;
        }
        Pepe memory _pepe =
            Pepe({
                master: _master,
                genotype: _genoType,
                canCozyAgain: 0,
                father: _father,
                mother: _mother,
                generation: _generation,
                coolDownIndex: tempCoolDownIndex
            });
        if (_generation == 0) {
            zeroGenPepes += 1;
        }
        pepeId = pepes.push(_pepe) - 1;
        addToWallet(_master, pepeId);
        emit PepeBorn(_mother, _father, pepeId);
        emit Transfer(address(0), _master, pepeId);
        return pepeId;
    }

    function setMiner(address _miner) public onlyOwner {
        require(miner == address(0));
        miner = _miner;
    }

    function minePepe(uint256 _seed, address _receiver)
        public
        stopWhenHalted
        returns (uint256)
    {
        require(msg.sender == miner);
        require(zeroGenPepes < MAX_ZERO_GEN_PEPES);
        return _newPepe(randomDNA(_seed), 0, 0, 0, _receiver);
    }

    function pepePremine(uint256 _amount) public onlyOwner stopWhenHalted {
        for (uint256 i = 0; i < _amount; i++) {
            require(zeroGenPepes <= MAX_PREMINE);
            _newPepe(
                randomDNA(
                    uint256(
                        keccak256(
                            abi.encodePacked(block.timestamp, pepes.length)
                        )
                    )
                ),
                0,
                0,
                0,
                owner
            );
        }
    }

    function cozyTime(
        uint256 _mother,
        uint256 _father,
        address _pepeReceiver
    ) external stopWhenHalted returns (bool) {
        require(_mother != _father);
        require(
            pepes[_mother].master == msg.sender ||
                approved[_mother] == msg.sender ||
                approvedForAll[pepes[_mother].master][msg.sender]
        );
        require(
            pepes[_father].master == msg.sender ||
                approved[_father] == msg.sender ||
                approvedForAll[pepes[_father].master][msg.sender]
        );
        require(
            now > pepes[_mother].canCozyAgain &&
                now > pepes[_father].canCozyAgain
        );
        require(
            pepes[_mother].mother != _father && pepes[_mother].father != _father
        );
        require(
            pepes[_father].mother != _mother && pepes[_father].father != _mother
        );
        Pepe storage father = pepes[_father];
        Pepe storage mother = pepes[_mother];
        approved[_father] = address(0);
        approved[_mother] = address(0);
        uint256[2] memory newGenotype =
            breed(father.genotype, mother.genotype, pepes.length);
        uint64 newGeneration;
        newGeneration = mother.generation + 1;
        if (newGeneration < father.generation + 1) {
            newGeneration = father.generation + 1;
        }
        _handleCoolDown(_mother);
        _handleCoolDown(_father);
        pepes[
            _newPepe(
                newGenotype,
                uint64(_mother),
                uint64(_father),
                newGeneration,
                _pepeReceiver
            )
        ]
            .canCozyAgain = mother.canCozyAgain;
        return true;
    }

    function _handleCoolDown(uint256 _pepeId) internal {
        Pepe storage tempPep = pepes[_pepeId];
        tempPep.canCozyAgain = uint64(
            now + cozyCoolDowns[tempPep.coolDownIndex]
        );
        if (tempPep.coolDownIndex < 14) {
            tempPep.coolDownIndex++;
        }
    }

    function setPepeName(uint256 _pepeId, bytes32 _name)
        public
        stopWhenHalted
        onlyPepeMaster(_pepeId)
        returns (bool)
    {
        require(
            pepeNames[_pepeId] ==
                0x0000000000000000000000000000000000000000000000000000000000000000
        );
        pepeNames[_pepeId] = _name;
        emit PepeNamed(_pepeId);
        return true;
    }

    function transferAndAuction(
        uint256 _pepeId,
        address _auction,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration
    ) public stopWhenHalted onlyPepeMaster(_pepeId) {
        _transfer(msg.sender, _auction, _pepeId);
        AuctionBase auction = AuctionBase(_auction);
        auction.startAuctionDirect(
            _pepeId,
            _beginPrice,
            _endPrice,
            _duration,
            msg.sender
        );
    }

    function approveAndBuy(
        uint256 _pepeId,
        address _auction,
        uint256 _cozyCandidate,
        bool _candidateAsFather
    ) public payable stopWhenHalted onlyPepeMaster(_cozyCandidate) {
        approved[_cozyCandidate] = _auction;
        CozyTimeAuction(_auction).buyCozy.value(msg.value)(
            _pepeId,
            _cozyCandidate,
            _candidateAsFather,
            msg.sender
        );
    }

    function approveAndBuyAffiliated(
        uint256 _pepeId,
        address _auction,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _affiliate
    ) public payable stopWhenHalted onlyPepeMaster(_cozyCandidate) {
        approved[_cozyCandidate] = _auction;
        CozyTimeAuction(_auction).buyCozyAffiliated.value(msg.value)(
            _pepeId,
            _cozyCandidate,
            _candidateAsFather,
            msg.sender,
            _affiliate
        );
    }

    function getPepe(uint256 _pepeId)
        public
        view
        returns (
            address master,
            uint256[2] genotype,
            uint64 canCozyAgain,
            uint64 generation,
            uint256 father,
            uint256 mother,
            bytes32 pepeName,
            uint8 coolDownIndex
        )
    {
        Pepe storage tempPep = pepes[_pepeId];
        master = tempPep.master;
        genotype = tempPep.genotype;
        canCozyAgain = tempPep.canCozyAgain;
        generation = tempPep.generation;
        father = tempPep.father;
        mother = tempPep.mother;
        pepeName = pepeNames[_pepeId];
        coolDownIndex = tempPep.coolDownIndex;
    }

    function getCozyAgain(uint256 _pepeId) public view returns (uint64) {
        return pepes[_pepeId].canCozyAgain;
    }

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function totalSupply() public view returns (uint256 total) {
        total = pepes.length - balances[address(0)];
        return total;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        balance = balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address _owner) {
        _owner = pepes[_tokenId].master;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        public
        constant
        returns (uint256 tokenId)
    {
        require(_index < balances[_owner]);
        return wallets[_owner][_index];
    }

    function addToWallet(address _owner, uint256 _tokenId) private {
        uint256[] storage wallet = wallets[_owner];
        uint256 balance = balances[_owner];
        if (balance < wallet.length) {
            wallet[balance] = _tokenId;
        } else {
            wallet.push(_tokenId);
        }
        balances[_owner] += 1;
    }

    function removeFromWallet(address _owner, uint256 _tokenId) private {
        uint256[] storage wallet = wallets[_owner];
        uint256 i = 0;
        for (; wallet[i] != _tokenId; i++) {}
        if (wallet[i] == _tokenId) {
            uint256 last = balances[_owner] - 1;
            if (last > 0) {
                wallet[i] = wallet[last];
            }
            balances[_owner] -= 1;
        }
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        pepes[_tokenId].master = _to;
        approved[_tokenId] = address(0);
        removeFromWallet(_from, _tokenId);
        addToWallet(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId)
        public
        stopWhenHalted
        onlyPepeMaster(_tokenId)
        returns (bool)
    {
        _transfer(msg.sender, _to, _tokenId);
        return true;
    }

    function approve(address _to, uint256 _tokenId)
        external
        stopWhenHalted
        onlyPepeMaster(_tokenId)
    {
        approved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)
        external
        stopWhenHalted
    {
        if (_approved) {
            approvedForAll[msg.sender][_operator] = true;
        } else {
            approvedForAll[msg.sender][_operator] = false;
        }
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address) {
        return approved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return approvedForAll[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        if (interfaceID == 0x80ac58cd || interfaceID == 0x01ffc9a7) {
            return true;
        }
        return false;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external stopWhenHalted {
        _safeTransferFromInternal(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) external stopWhenHalted {
        _safeTransferFromInternal(_from, _to, _tokenId, _data);
    }

    function _safeTransferFromInternal(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) internal onlyAllowed(_tokenId) {
        require(pepes[_tokenId].master == _from);
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
        if (isContract(_to)) {
            require(
                ERC721TokenReceiver(_to).onERC721Received(
                    _from,
                    _tokenId,
                    _data
                ) ==
                    bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
            );
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public stopWhenHalted onlyAllowed(_tokenId) returns (bool) {
        require(pepes[_tokenId].master == _from);
        require(_to != address(0));
        _transfer(_from, _to, _tokenId);
        return true;
    }

    function isContract(address _address) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }
}

contract PepeReborn is Ownable, Usernames {
    uint32[15] public cozyCoolDowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(15 minutes),
        uint32(30 minutes),
        uint32(45 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];
    struct Pepe {
        address master;
        uint256[2] genotype;
        uint64 canCozyAgain;
        uint64 generation;
        uint64 father;
        uint64 mother;
        uint8 coolDownIndex;
    }
    struct UndeadPepeMutable {
        address master;
        uint64 canCozyAgain;
        uint8 coolDownIndex;
        bool resurrected;
    }
    mapping(uint256 => bytes32) public pepeNames;
    Pepe[] private rebornPepes;
    mapping(uint256 => UndeadPepeMutable) private undeadPepes;
    address private PEPE_UNDEAD_ADDRRESS;
    address private PEPE_AUCTION_SALE_UNDEAD_ADDRESS;
    address private COZY_TIME_AUCTION_UNDEAD_ADDRESS;
    GenePoolInterface private genePool;
    uint256 private constant REBORN_PEPE_0 = 5497;
    bool public constant implementsERC721 = true;
    string public constant name = "Crypto Pepe Reborn";
    string public constant symbol = "CPRE";
    string public baseTokenURI = "https://api.cryptopepes.lol/getPepe/";
    string private contractUri =
        "https://cryptopepes.lol/contract-metadata.json";
    mapping(address => uint256[]) private wallets;
    mapping(uint256 => uint256) private walletIndex;
    mapping(uint256 => address) public approved;
    mapping(address => mapping(address => bool)) public approvedForAll;
    uint256 private preminedPepes = 0;
    uint256 private constant MAX_PREMINE = 1100;
    modifier onlyPepeMaster(uint256 pepeId) {
        require(_ownerOf(pepeId) == msg.sender);
        _;
    }
    modifier onlyAllowed(uint256 pepeId) {
        address master = _ownerOf(pepeId);
        require(
            msg.sender == master ||
                msg.sender == approved[pepeId] ||
                approvedForAll[master][msg.sender]
        );
        _;
    }
    event PepeBorn(
        uint256 indexed mother,
        uint256 indexed father,
        uint256 indexed pepeId
    );
    event PepeNamed(uint256 indexed pepeId);

    constructor(
        address baseAddress,
        address saleAddress,
        address cozyAddress,
        address genePoolAddress
    ) public {
        PEPE_UNDEAD_ADDRRESS = baseAddress;
        PEPE_AUCTION_SALE_UNDEAD_ADDRESS = saleAddress;
        COZY_TIME_AUCTION_UNDEAD_ADDRESS = cozyAddress;
        setGenePool(genePoolAddress);
    }

    function _newPepe(
        uint256[2] _genoType,
        uint64 _mother,
        uint64 _father,
        uint64 _generation,
        address _master
    ) internal returns (uint256 pepeId) {
        uint8 tempCoolDownIndex;
        tempCoolDownIndex = uint8(_generation / 2);
        if (_generation > 28) {
            tempCoolDownIndex = 14;
        }
        Pepe memory _pepe =
            Pepe({
                master: _master,
                genotype: _genoType,
                canCozyAgain: 0,
                father: _father,
                mother: _mother,
                generation: _generation,
                coolDownIndex: tempCoolDownIndex
            });
        pepeId = rebornPepes.push(_pepe) + REBORN_PEPE_0 - 1;
        addToWallet(_master, pepeId);
        emit PepeBorn(_mother, _father, pepeId);
        emit Transfer(address(0), _master, pepeId);
        return pepeId;
    }

    function pepePremine(uint256 _amount) public onlyOwner {
        for (uint256 i = 0; i < _amount; i++) {
            require(preminedPepes < MAX_PREMINE);
            _newPepe(
                genePool.randomDNA(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                block.timestamp,
                                (REBORN_PEPE_0 + rebornPepes.length)
                            )
                        )
                    )
                ),
                0,
                0,
                0,
                owner
            );
            ++preminedPepes;
        }
    }

    function cozyTime(
        uint256 _mother,
        uint256 _father,
        address _pepeReceiver
    ) external returns (bool) {
        require(_mother != _father);
        checkResurrected(_mother);
        checkResurrected(_father);
        Pepe memory mother = _getPepe(_mother);
        Pepe memory father = _getPepe(_father);
        require(
            mother.master == msg.sender ||
                approved[_mother] == msg.sender ||
                approvedForAll[mother.master][msg.sender]
        );
        require(
            father.master == msg.sender ||
                approved[_father] == msg.sender ||
                approvedForAll[father.master][msg.sender]
        );
        require(now > mother.canCozyAgain && now > father.canCozyAgain);
        require(mother.father != _father && mother.mother != _father);
        require(father.mother != _mother && father.father != _mother);
        approved[_father] = address(0);
        approved[_mother] = address(0);
        uint256[2] memory newGenotype =
            genePool.breed(
                father.genotype,
                mother.genotype,
                REBORN_PEPE_0 + rebornPepes.length
            );
        uint64 newGeneration;
        newGeneration = mother.generation + 1;
        if (newGeneration < father.generation + 1) {
            newGeneration = father.generation + 1;
        }
        uint64 motherCanCozyAgain = _handleCoolDown(_mother);
        _handleCoolDown(_father);
        uint256 pepeId =
            _newPepe(
                newGenotype,
                uint64(_mother),
                uint64(_father),
                newGeneration,
                _pepeReceiver
            );
        rebornPepes[rebornPepeIdToIndex(pepeId)]
            .canCozyAgain = motherCanCozyAgain;
        return true;
    }

    function _handleCoolDown(uint256 pepeId) internal returns (uint64) {
        if (pepeId >= REBORN_PEPE_0) {
            Pepe storage tempPep1 = rebornPepes[pepeId];
            tempPep1.canCozyAgain = uint64(
                now + cozyCoolDowns[tempPep1.coolDownIndex]
            );
            if (tempPep1.coolDownIndex < 14) {
                tempPep1.coolDownIndex++;
            }
            return tempPep1.canCozyAgain;
        } else {
            UndeadPepeMutable storage tempPep2 = undeadPepes[pepeId];
            tempPep2.canCozyAgain = uint64(
                now + cozyCoolDowns[tempPep2.coolDownIndex]
            );
            if (tempPep2.coolDownIndex < 14) {
                tempPep2.coolDownIndex++;
            }
            return tempPep2.canCozyAgain;
        }
    }

    function setPepeName(uint256 pepeId, bytes32 _name)
        public
        onlyPepeMaster(pepeId)
        returns (bool)
    {
        require(
            pepeNames[pepeId] ==
                0x0000000000000000000000000000000000000000000000000000000000000000
        );
        pepeNames[pepeId] = _name;
        emit PepeNamed(pepeId);
        return true;
    }

    function transferAndAuction(
        uint256 pepeId,
        address _auction,
        uint256 _beginPrice,
        uint256 _endPrice,
        uint64 _duration
    ) public onlyPepeMaster(pepeId) {
        _transfer(msg.sender, _auction, pepeId);
        AuctionBase auction = AuctionBase(_auction);
        auction.startAuctionDirect(
            pepeId,
            _beginPrice,
            _endPrice,
            _duration,
            msg.sender
        );
    }

    function approveAndBuy(
        uint256 pepeId,
        address _auction,
        uint256 _cozyCandidate,
        bool _candidateAsFather
    ) public payable onlyPepeMaster(_cozyCandidate) {
        checkResurrected(pepeId);
        approved[_cozyCandidate] = _auction;
        RebornCozyTimeAuction(_auction).buyCozy.value(msg.value)(
            pepeId,
            _cozyCandidate,
            _candidateAsFather,
            msg.sender
        );
    }

    function approveAndBuyAffiliated(
        uint256 pepeId,
        address _auction,
        uint256 _cozyCandidate,
        bool _candidateAsFather,
        address _affiliate
    ) public payable onlyPepeMaster(_cozyCandidate) {
        checkResurrected(pepeId);
        approved[_cozyCandidate] = _auction;
        RebornCozyTimeAuction(_auction).buyCozyAffiliated.value(msg.value)(
            pepeId,
            _cozyCandidate,
            _candidateAsFather,
            msg.sender,
            _affiliate
        );
    }

    function getCozyAgain(uint256 pepeId) public view returns (uint64) {
        return _getPepe(pepeId).canCozyAgain;
    }

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 pepeId
    );
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed pepeId
    );
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function totalSupply() public view returns (uint256) {
        return REBORN_PEPE_0 + rebornPepes.length - 1;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return wallets[_owner].length;
    }

    function ownerOf(uint256 pepeId) external view returns (address) {
        return _getPepe(pepeId).master;
    }

    function _ownerOf(uint256 pepeId) internal view returns (address) {
        return _getPepe(pepeId).master;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        public
        constant
        returns (uint256 pepeId)
    {
        require(_index < wallets[_owner].length);
        return wallets[_owner][_index];
    }

    function addToWallet(address _owner, uint256 pepeId) private {
        walletIndex[pepeId] = wallets[_owner].length;
        wallets[_owner].push(pepeId);
    }

    function removeFromWallet(address _owner, uint256 pepeId) private {
        if (
            walletIndex[pepeId] == 0 &&
            (wallets[_owner].length == 0 || wallets[_owner][0] != pepeId)
        ) return;
        uint256 tokenIndex = walletIndex[pepeId];
        uint256 lastTokenIndex = wallets[_owner].length - 1;
        uint256 lastToken = wallets[_owner][lastTokenIndex];
        wallets[_owner][tokenIndex] = lastToken;
        wallets[_owner].length--;
        walletIndex[pepeId] = 0;
        walletIndex[lastToken] = tokenIndex;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 pepeId
    ) internal {
        checkResurrected(pepeId);
        if (pepeId >= REBORN_PEPE_0)
            rebornPepes[rebornPepeIdToIndex(pepeId)].master = _to;
        else undeadPepes[pepeId].master = _to;
        approved[pepeId] = address(0);
        removeFromWallet(_from, pepeId);
        addToWallet(_to, pepeId);
        emit Transfer(_from, _to, pepeId);
    }

    function transfer(address _to, uint256 pepeId)
        public
        onlyPepeMaster(pepeId)
        returns (bool)
    {
        _transfer(msg.sender, _to, pepeId);
        return true;
    }

    function approve(address _to, uint256 pepeId)
        external
        onlyPepeMaster(pepeId)
    {
        approved[pepeId] = _to;
        emit Approval(msg.sender, _to, pepeId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        approvedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 pepeId) external view returns (address) {
        return approved[pepeId];
    }

    function isApprovedForAll(address _owner, address _operator)
        external
        view
        returns (bool)
    {
        return approvedForAll[_owner][_operator];
    }

    function supportsInterface(bytes4 interfaceID)
        external
        pure
        returns (bool)
    {
        if (
            interfaceID == 0x01ffc9a7 ||
            interfaceID == 0x80ac58cd ||
            interfaceID == 0x780e9d63 ||
            interfaceID == 0x4f558e79 ||
            interfaceID == 0x5b5e139f
        ) {
            return true;
        }
        return false;
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 pepeId
    ) external {
        _safeTransferFromInternal(_from, _to, pepeId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 pepeId,
        bytes _data
    ) external {
        _safeTransferFromInternal(_from, _to, pepeId, _data);
    }

    function _safeTransferFromInternal(
        address _from,
        address _to,
        uint256 pepeId,
        bytes _data
    ) internal onlyAllowed(pepeId) {
        require(_ownerOf(pepeId) == _from);
        require(_to != address(0));
        _transfer(_from, _to, pepeId);
        if (isContract(_to)) {
            require(
                ERC721TokenReceiver(_to).onERC721Received(
                    _from,
                    pepeId,
                    _data
                ) ==
                    bytes4(keccak256("onERC721Received(address,uint256,bytes)"))
            );
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 pepeId
    ) public onlyAllowed(pepeId) returns (bool) {
        require(_ownerOf(pepeId) == _from);
        require(_to != address(0));
        _transfer(_from, _to, pepeId);
        return true;
    }

    function isContract(address _address) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    function exists(uint256 pepeId) public view returns (bool) {
        return 0 < pepeId && pepeId <= (REBORN_PEPE_0 + rebornPepes.length - 1);
    }

    function tokenURI(uint256 pepeId) public view returns (string) {
        require(exists(pepeId));
        return string(abi.encodePacked(baseTokenURI, toString(pepeId)));
    }

    function setBaseTokenURI(string baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function contractURI() public view returns (string) {
        return contractUri;
    }

    function setContractURI(string uri) public onlyOwner {
        contractUri = uri;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }

    function getPepe(uint256 pepeId)
        public
        view
        returns (
            address master,
            uint256[2] genotype,
            uint64 canCozyAgain,
            uint64 generation,
            uint256 father,
            uint256 mother,
            bytes32 pepeName,
            uint8 coolDownIndex
        )
    {
        Pepe memory pepe = _getPepe(pepeId);
        master = pepe.master;
        genotype = pepe.genotype;
        canCozyAgain = pepe.canCozyAgain;
        generation = pepe.generation;
        father = pepe.father;
        mother = pepe.mother;
        pepeName = pepeNames[pepeId];
        coolDownIndex = pepe.coolDownIndex;
    }

    function _getPepe(uint256 pepeId) internal view returns (Pepe memory) {
        if (pepeId >= REBORN_PEPE_0) {
            uint256 index = rebornPepeIdToIndex(pepeId);
            require(index < rebornPepes.length);
            return rebornPepes[index];
        } else {
            (
                address master,
                uint256[2] memory genotype,
                uint64 canCozyAgain,
                uint64 generation,
                uint256 father,
                uint256 mother,
                ,
                uint8 coolDownIndex
            ) = _getUndeadPepe(pepeId);
            return
                Pepe({
                    master: master,
                    genotype: genotype,
                    canCozyAgain: canCozyAgain,
                    father: uint64(father),
                    mother: uint64(mother),
                    generation: generation,
                    coolDownIndex: coolDownIndex
                });
        }
    }

    function _getUndeadPepe(uint256 pepeId)
        internal
        view
        returns (
            address master,
            uint256[2] genotype,
            uint64 canCozyAgain,
            uint64 generation,
            uint256 father,
            uint256 mother,
            bytes32 pepeName,
            uint8 coolDownIndex
        )
    {
        (
            master,
            genotype,
            canCozyAgain,
            generation,
            father,
            mother,
            pepeName,
            coolDownIndex
        ) = PepeBase(PEPE_UNDEAD_ADDRRESS).getPepe(pepeId);
        if (undeadPepes[pepeId].resurrected) {
            master = undeadPepes[pepeId].master;
            canCozyAgain = undeadPepes[pepeId].canCozyAgain;
            pepeName = pepeNames[pepeId];
            coolDownIndex = undeadPepes[pepeId].coolDownIndex;
        } else if (
            master == PEPE_AUCTION_SALE_UNDEAD_ADDRESS ||
            master == COZY_TIME_AUCTION_UNDEAD_ADDRESS
        ) {
            (master, , , , , ) = AuctionBase(master).auctions(pepeId);
        }
    }

    event PepeResurrected(uint256 pepeId);

    function checkResurrected(uint256 pepeId) public {
        if (pepeId >= REBORN_PEPE_0) return;
        if (undeadPepes[pepeId].resurrected) return;
        (
            address _master,
            ,
            uint64 _canCozyAgain,
            ,
            ,
            ,
            bytes32 _pepeName,
            uint8 _coolDownIndex
        ) = _getUndeadPepe(pepeId);
        undeadPepes[pepeId] = UndeadPepeMutable({
            master: _master,
            canCozyAgain: _canCozyAgain,
            coolDownIndex: _coolDownIndex,
            resurrected: true
        });
        if (
            _pepeName !=
            0x0000000000000000000000000000000000000000000000000000000000000000
        ) pepeNames[pepeId] = _pepeName;
        addToWallet(_master, pepeId);
        emit PepeResurrected(pepeId);
    }

    function rebornPepeIdToIndex(uint256 pepeId)
        internal
        pure
        returns (uint256)
    {
        require(pepeId >= REBORN_PEPE_0);
        return pepeId - REBORN_PEPE_0;
    }

    function setPrevContracts(
        address baseaddr,
        address saleauctionaddr,
        address cozyauctionaddr
    ) public onlyOwner {
        PEPE_UNDEAD_ADDRRESS = baseaddr;
        PEPE_AUCTION_SALE_UNDEAD_ADDRESS = saleauctionaddr;
        COZY_TIME_AUCTION_UNDEAD_ADDRESS = cozyauctionaddr;
    }

    function setGenePool(address genePoolAddress) public onlyOwner {
        GenePoolInterface pool = GenePoolInterface(genePoolAddress);
        require(pool.isGenePool());
        genePool = pool;
    }
}
