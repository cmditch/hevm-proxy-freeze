pragma solidity ^0.4.24;

/////////////////////////////
// Start of proxy contract
//
contract Proxyable {
    address masterCopy;
}

contract Proxy is Proxyable {

    /// @dev Constructor function sets address of master copy contract.
    /// @param _masterCopy Master copy address.
    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    /// @dev Fallback function forwards all transactions and returns all received return data.
    function ()
        external
        payable
    {
        assembly {
            let masterCopy := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(sub(gas, 703), masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}
//
// End of proxy contract
/////////////////////////////



/*

Say we have a very fat contract, and we want to save money by using a proxy.
Say also, this fat contract needs to ocassionally spawn off another fat contract.

HEVM seems to play fine with a single proxy,
but creating a proxy within a proxy seems problematic.

*/

contract Foo is Proxyable {
    event FooInitialized(uint lifeMeaning);

    bool public initialized;
    uint public lifeMeaning;
    address public masterCopy;

    function initialize(uint lifeMeaning_) public {
        require(!initialized, "already initialized");
        lifeMeaning = lifeMeaning_;
        initialized = true;
        emit FooInitialized(lifeMeaning_);
    }
}

// Foo is the second/inner proxy, or proxy within proxy. Foo's just return some number.
contract FooFactory {
    event FooCreatedFromFactory(address foo);
    address fooMasterCopy;

    constructor(address fooMasterCopy_) public {
        fooMasterCopy = fooMasterCopy_;
    }

    function create(uint lifeMeaning_) public returns (Foo foo) {
        foo = Foo(new Proxy(fooMasterCopy));
        foo.initialize(lifeMeaning_);
        emit FooCreatedFromFactory(foo);
    }
}


// Bar is the first/outer proxy, it gets a FooFactory to create Foo's.
contract Bar is Proxyable {
    event FooCreatedFromBar(address foo);

    bool public initialized;
    FooFactory public fooFactory;

    function initialize(FooFactory fooFactory_) public {
        require(!initialized, "already initialized");
        fooFactory = fooFactory_;
        initialized = true;
    }

    function createFoo(uint lifeMeaning_) public returns (Foo foo) {
        foo = fooFactory.create(lifeMeaning_);
        emit FooCreatedFromBar(address(foo));
    }
}


// BarFactory is where all the magic begins.
contract BarFactory {
    event BarCreatedFromBarFactory(address bar);
    FooFactory fooFactory;
    Bar masterBar;

    constructor() public {
        Foo fooMasterCopy = new Foo();
        fooFactory = new FooFactory(fooMasterCopy);
        masterBar = new Bar();
    }

    function create() public returns (Bar bar) {
        bar = Bar(new Proxy(masterBar));
        bar.initialize(fooFactory);
        emit BarCreatedFromBarFactory(bar);
    }
}