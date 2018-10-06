pragma solidity ^0.4.24;

import "ds-test/test.sol";

import "./Foo.sol";

contract FooTest is DSTest {
    FooFactory fooFactory;
    Foo fooMasterCopy;
    Foo fooProxyCopy;
    BarFactory barFactory;
    Bar bar;

    function setUp() public {
        fooMasterCopy = new Foo();
        fooFactory = new FooFactory(fooMasterCopy);
        fooProxyCopy = fooFactory.create(42);

        barFactory = new BarFactory();
        bar = barFactory.create();
    }

    // These tests pass fine. There is no nested proxying happening here.

    function test_fooMaster_not_initialized() public {
        assertTrue(!fooMasterCopy.initialized());
    }

    function test_fooProxy_initialized() public {
        assertTrue(fooProxyCopy.initialized());
    }

    function test_fooProxy_meaning_of_life() public {
        assertTrue(fooProxyCopy.lifeMeaning() == 42);
    }

    // These tests fail, proxy within proxy inception madness.

    function test_bar() public {
        Foo foo = bar.createFoo(24);
        assertEq(foo.lifeMeaning(), 24);
    }

}
