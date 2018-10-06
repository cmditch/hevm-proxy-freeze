pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./HevmProxy.sol";

contract HevmProxyTest is DSTest {
    HevmProxy proxy;

    function setUp() public {
        proxy = new HevmProxy();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
