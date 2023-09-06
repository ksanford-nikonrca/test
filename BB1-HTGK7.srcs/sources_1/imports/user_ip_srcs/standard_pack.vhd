
--------------------------------------------------------------------------------
-- NN     NN  RRRRRRRR    CCCCCCC      AAA
-- NNN    NN  RR     RR  CCC    CC    AA AA
-- NNNN   NN  RR     RR  CC          AA   AA
-- NNNN   NN  RR    RR   CC         AA     AA
-- NN NN  NN  RRRRRRR    CC         AAAAAAAAA
-- NN  NN NN  RR  RR     CC         AA     AA
-- NN   NNNN  RR   RR    CC         AA     AA
-- NN    NNN  RR    RR   CCC    CC  AA     AA
-- NN     NN  RR     RR   CCCCCCC   AA     AA
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- MODULE NAME : standard_pack
-- DESIGNER    : James King
-- BRIEF       : Collection of commonly used functions and procedures
-- HISTORY     : Initial 22-09-2021
-- 
--------------------------------------------------------------------------------
library ieee; use ieee.std_logic_1164.all;
              use ieee.numeric_std.all;
              use ieee.math_real.all;

--------------------------------------------------------------------------------
-- PACKAGE
--------------------------------------------------------------------------------

package standard_pack is
  ------------------------------------------------------------------------------
  -- TYPE DECLARATION
  ------------------------------------------------------------------------------
  type NaturalArrayType is array(natural range <>) of natural;
  
  ------------------------------------------------------------------------------
  -- CONSTANT DECLARATION
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- FUNCTION DECLARATION
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Simple MUX
  ------------------------------------------------------------------------------
  -- STD_LOGIC
  function ILIF (
    CHK  : std_logic;
    L    : std_logic;
    R    : std_logic)
    return std_logic;

  -- STD_LOGIC_VECTOR
  function ILIF (
    CHK :  std_logic;
    L   :  std_logic_vector;
    R   :  std_logic_vector)
    return std_logic_vector;

  ------------------------------------------------------------------------------
  -- Log Base 2
  ------------------------------------------------------------------------------
  -- UNSIGNED
  function LOG2
    (ARG   : unsigned)
    return  natural;
  
  -- NATURAL
  function LOG2
    (ARG   : natural)
    return  natural;

  ------------------------------------------------------------------------------
  -- Custom Resize
  ------------------------------------------------------------------------------
  -- STD_LOGIC_VECTOR
  function ResizeFunc
    (ARG   : std_logic_vector;
     SIZE  : natural;
     PAD   : boolean := TRUE)           -- TRUE = Resize to the Left
    return  std_logic_vector;
  --UNSIGNED
  function ResizeFunc ----------------------------------------------- UNSIGNED --
    (ARG   : unsigned;
     SIZE  : natural;
     PAD   : boolean := TRUE)           -- TRUE = Resize to the Left
    return  unsigned;

  ------------------------------------------------------------------------------
  -- Minimum and Maximum Functions
  ------------------------------------------------------------------------------
  -- Minimum Unsigned
  function minFunc
    (LEFTu  : unsigned;
     RIGHTu : unsigned)
    return    unsigned;

  -- Minimum Integer
  function minFunc
    (LEFTi  : integer;
     RIGHTi : integer)
     return   integer;

  -- Minimum Sort Naturals
  --function minFunc
  --  (ARG     : NaturalArrayType;
  --   DEFAULT : natural := 0)
  --  return    natural;
  
  -- Maximum Unsigned
  function maxFunc
    (LEFTu  : unsigned;
     RIGHTu : unsigned)
    return    unsigned;

  -- Maximum Integer
  function maxFunc
    (LEFTi  : integer;
     RIGHTi : integer)
     return   integer;

  -- Maximum Sort Naturals
  --function maxFunc
  --  (ARG     : NaturalArrayType;
  --   DEFAULT : natural := 0)
  --   return    natural;
  -----------------------------------------------------------------------------
  
  
  ------------------------------------------------------------------------------
  -- PROCEDURE DECLARATION
  ------------------------------------------------------------------------------
  ------------------------------------------------------------------------------
  -- Flip-Flop
  ------------------------------------------------------------------------------
  -- STD_LOGIC
  procedure FlipFlop (
    signal   q      : out std_logic;
    signal   d      : in  std_logic;
    constant INIT   : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1');

  -- STD_LOGIC_VECTOR
  procedure FlipFlop (
    signal   q      : out std_logic_vector;
    signal   d      : in  std_logic_vector;
    constant INIT   : in  std_logic_vector;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1');

  -- UNSIGNED
  procedure FlipFlop (
    signal   q      : out unsigned;
    signal   d      : in  unsigned;
    constant INIT   : in  unsigned;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1');

  -- SIGNED
  procedure FlipFlop (
    signal   q      : out signed;
    signal   d      : in  signed;
    constant INIT   : in  signed;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1');

  ------------------------------------------------------------------------------
  -- Sticky Bit
  ------------------------------------------------------------------------------
  -- STD_LOGIC
  procedure StickyBit (
    signal   q      : out std_logic;
    signal   d      : in  std_logic;
    constant INIT   : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  std_logic);
  
  -- STD_LOGIC_VECTOR
  procedure StickyBit (
    signal   q      : out std_logic_vector;
    signal   d      : in  std_logic_vector;
    constant INIT   : in  std_logic_vector;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  std_logic_vector);
  -- UNSIGNED
  procedure StickyBit (
    signal   q      : out unsigned;
    signal   d      : in  unsigned;
    constant INIT   : in  unsigned;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  unsigned);
  -- SIGNED
  procedure StickyBit (
    signal   q      : out signed;
    signal   d      : in  signed;
    constant INIT   : in  signed;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  signed);
  
  -- ONE SHOT
--  procedure OneShot (
--    signal   q      : inout std_logic;
--    constant d0     : in    std_logic;
--    signal   d1     : inout std_logic;
--    signal   rst    : in    std_logic;
--    signal   clk    : in    std_logic;
--    constant EDGE   : in    std_logic := '1');
  
  procedure OneShot (
    signal   q      : out std_logic;
    signal   d0     : in  std_logic;
    signal   d1     : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant EDGE   : in  std_logic := '1');
      
  -- ARBITER
--  procedure Arbiter (
--    signal   grant    : inout unsigned;
--    signal   grantIdx : inout unsigned;
--    signal   rst      : in    std_logic;
--    signal   clk      : in    std_logic;
--    signal   request  : in    std_logic;
--    constant adv      : in    std_logic := '1');
                          
end package standard_pack;

package body standard_pack is
  ------------------------------------------------------------------------------
  -- FUNCTION BODIES
  ------------------------------------------------------------------------------
  -- STD_LOGIC Inline If
  function ILIF (
    CHK :  std_logic;
    L   :  std_logic;
    R   :  std_logic)
    return std_logic is
  begin
    if (CHK = '1') then
      return L;
    else
      return R;
    end if;
  end function ILIF;

  -- STD_LOGIC_VECTOR Inline If
  function ILIF (
    CHK :  std_logic;
    L   :  std_logic_vector;
    R   :  std_logic_vector)
    return std_logic_vector is
  begin
    if (CHK = '1') then
      return L;
    else
      return R;
    end if;
  end function ILIF;

  -- UNSIGNED LOG2
  function LOG2 (
    ARG   : unsigned)
    return  natural is
  begin
    log2loop: for i in ARG'range loop
      if (ARG(i) = '1') then
        return i;
      end if;
    end loop log2loop;
    return 0;
  end function LOG2;

  -- NATURAL LOG2
  function LOG2 (
    ARG   : natural)
    return  natural is
    variable uArg : unsigned(30 downto 0) := to_unsigned(ARG, 31);
  begin
    return LOG2(uArg);
  end function LOG2;

  -- STD_LOGIC_VECTOR
  function ResizeFunc 
    (ARG   : std_logic_vector;
     SIZE  : natural;
     PAD   : boolean := TRUE)
     return  std_logic_vector is
  begin
    return std_logic_vector(ResizeFunc(unsigned(ARG),SIZE,PAD));
  end function ResizeFunc;

  -- UNSIGNED RESIZE
  function ResizeFunc
    (ARG   : unsigned;
     SIZE  : natural;
     PAD   : boolean := TRUE)
     return  unsigned is
     
     variable rtn : unsigned(SIZE      -1 downto 0) := (others=>'0');
     variable var : unsigned(ARG'length-1 downto 0) := ARG;
  begin
    if (PAD = TRUE) then
      rtn := resize(var,SIZE);
    else
      if (ARG'length < SIZE) then
          rtn(rtn'left downto SIZE-var'length) := var; -- pad the right right
        else
          rtn := var(var'left downto var'length-SIZE); -- truncate
        end if;
    end if;
    return rtn;
  end function ResizeFunc;

  -- MINIMUM UNSIGNED
  function minFunc
    (LEFTu  : unsigned;
     RIGHTu : unsigned)
     return   unsigned is
  begin
    if (LEFTu < RIGHTu) then
      return LEFTu;
    else
      return RIGHTu;
    end if;
  end function minFunc;

  -- MINIMUM INTEGER
  function minFunc
    (LEFTi  : integer;
     RIGHTi : integer)
     return   integer is
  begin
    if (LEFTi < RIGHTi) then
      return LEFTi;
    else
      return RIGHTi;
    end if;
  end function minFunc;

  -- MINIMUM NATURAL SORT
  --function minFunc
  --  (ARG     : NaturalArrayType;
  --   DEFAULT : natural := 0)
  --   return    natural is
  --
  --   variable varArray   : NaturalArrayType(0 to ARG'length-1);
  --   constant ARG_WIDTH  : natural := ARG'length;
  --   variable SORT_LEFT  : natural;
  --   variable SORT_RIGHT : natural;
  --begin
  --  varArray := ARG;
  --  if (ARG_WIDTH = 0) then
  --    return DEFAULT;                  -- Not an array return a user default
  --  elsif (ARG_WIDTH = 1) then
  --    return ARG(0);                   -- Single value is the min
  --  elsif (ARG_WIDTH = 2) then ----------------------------------------------------
  --    return minFunc(varArray(varArray'left), varArray(varArray'right));
  --  else -----------------------------------------------------------------------
  --    varSortLeft  := minFunc(varArray(0           to ARG_WIDTH/2-1));
  --    varSortRight := minFunc(varArray(ARG_WIDTH/2 to ARG_WIDTH-1  ));
  --    return minFunc(varSortLeft, varSortRight);
  --  end if;
  --end function minFunc;
  
  -- MAXIMUM UNSIGNED
  function maxFunc
    (LEFTu  : unsigned;
     RIGHTu : unsigned)
     return   unsigned is
  begin
    if (LEFTu > RIGHTu) then
      return LEFTu;
    else
      return RIGHTu;
    end if;
  end function maxFunc;

  -- MAXIMUM INTEGER
  function maxFunc
    (LEFTi  : integer;
     RIGHTi : integer)
     return   integer is
  begin
    if (LEFTi > RIGHTi) then
      return LEFTi;
    else return RIGHTi;
    end if;
  end function maxFunc;

  -- MAXIMUM NATURAL SORT
  --function maxFunc
  --  (ARG     : NaturalArrayType;
  --   DEFAULT : natural := 0)
  --   return    natural is
  --
  --   variable varArray     : NaturalArrayType(0 to ARG'length-1);
  --   constant ARG_WIDTH    : natural := ARG'length;
  --   variable varSortLeft  : natural;
  --   variable varSortRight : natural;
  --begin
  --  varArray := ARG;
  --  if (ARG_WIDTH = 0) then
  --    return DEFAULT;                  -- not an array return a user default
  --  elsif (ARG_WIDTH = 1) then
  --    return ARG(0);                   -- single value is the Max
  --  elsif (ARG_WIDTH = 2) then
  --    return maxFunc(varArray(varArray'left), varArray(varArray'right)); -- Recursive
  --  else
  --    varSortLeft  := maxFunc(varArray(0           to ARG_WIDTH/2-1));
  --    varSortRight := maxFunc(varArray(ARG_WIDTH/2 to ARG_WIDTH-1  ));
  --    return maxFunc(varSortLeft, varSortRight);  -- Recursive
  --  end if;
  --end function maxFunc;
  
  ------------------------------------------------------------------------------
  -- PROCEDURE BODIES
  ------------------------------------------------------------------------------
  -- STD_LOGIC Flip Flop
  procedure FlipFlop (
    signal   q      : out std_logic;
    signal   d      : in  std_logic;
    constant INIT   : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1') is
  begin
    if (rising_edge(clk)) then
      if (rst /= '0') then
        q <= INIT;
      elsif (enable = '1') then
        q <= d;
      end if;
    end if;
  end procedure FlipFlop;

  -- STD_LOGIC_VECTOR Flip Flop
  procedure FlipFlop (
    signal   q      : out std_logic_vector;
    signal   d      : in  std_logic_vector;
    constant INIT   : in  std_logic_vector;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1') is
  begin
    if (rising_edge(clk)) then
      if (rst /= '0') then
        q <= INIT;
      elsif (enable = '1') then
        q <= d;
      end if;
    end if;
  end procedure FlipFlop;

  -- UNSIGNED Flip Flop
  procedure FlipFlop (
    signal   q      : out unsigned;
    signal   d      : in  unsigned;
    constant INIT   : in  unsigned;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1') is
  begin
    if (rising_edge(clk)) then
      if (rst /= '0') then
        q <= INIT;
      elsif (enable = '1') then
        q <= d;
      end if;
    end if;
  end procedure FlipFlop;

  -- SIGNED Flip Flop
  procedure FlipFlop (
    signal   q      : out signed;
    signal   d      : in  signed;
    constant INIT   : in  signed;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant   enable : in  std_logic := '1') is
  begin
    if (rising_edge(clk)) then
      if (rst /= '0') then
        q <= INIT;
      elsif (enable = '1') then
        q <= d;
      end if;
    end if;
  end procedure FlipFlop;

  ------------------------------------------------------------------------------
  -- Sticky Bit
  --
  -- Hold bit(s) to non-start value until cleared
  ------------------------------------------------------------------------------
  -- STD_LOGIC
  procedure StickyBit (
    signal   q      : out std_logic;
    signal   d      : in  std_logic;
    constant INIT   : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  std_logic) is
  begin
      if (rising_edge(clk)) then
        if (rst /= '1') then
          -- Clear to initial value on reset
          q <= INIT;
        -- When D becomes not the initial value it is stuck to that value until
        -- clear = 1
        elsif (d = not(INIT) or clr = '1') then
          -- When clear is high then we set Q back to INIT
          if (clr = '1') then
            q <= INIT;
          else
            q <= d;
          end if;
        end if;
      end if;
  end procedure StickyBit;

  -- STD_LOGIC_VECTOR
  procedure StickyBit (
    signal   q      : out std_logic_vector;
    signal   d      : in  std_logic_vector;
    constant INIT   : in  std_logic_vector;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  std_logic_vector) is
  begin
    for i in q'range loop
      if (rising_edge(clk)) then
        if (rst /= '1') then
          -- Clear to initial value on reset
          q(i) <= INIT(i);
        -- When D becomes not the initial value it is stuck to that value until
        -- clear = 1
        elsif (d(i) = not(INIT(i)) or clr(i) = '1') then
          -- When clear is high then we set Q back to INIT
          if (clr(i) = '1') then
            q(i) <= INIT(i);
          else
            q(i) <= d(i);
          end if;
        end if;
      end if;
    end loop;
  end procedure StickyBit;
  
  -- UNSIGNED
  procedure StickyBit (
    signal   q      : out unsigned;
    signal   d      : in  unsigned;
    constant INIT   : in  unsigned;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  unsigned) is
  begin
    for i in q'range loop
      if (rising_edge(clk)) then
        if (rst /= '1') then
          -- Clear to initial value on reset
          q(i) <= INIT(i);
        -- When D becomes not the initial value it is stuck to that value until
        -- clear = 1
        elsif (d(i) = not(INIT(i)) or clr(i) = '1') then
          -- When clear is high then we set Q back to INIT
          if (clr(i) = '1') then
            q(i) <= INIT(i);
          else
            q(i) <= d(i);
          end if;
        end if;
      end if;
    end loop;
  end procedure StickyBit;
  
  -- SIGNED
  procedure StickyBit (
    signal   q      : out signed;
    signal   d      : in  signed;
    constant INIT   : in  signed;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    signal   clr    : in  signed) is
  begin
    for i in q'range loop
      if (rising_edge(clk)) then
        if (rst /= '1') then
          -- Clear to initial value on reset
          q(i) <= INIT(i);
        -- When D becomes not the initial value it is stuck to that value until
        -- clear = 1
        elsif (d(i) = not(INIT(i)) or clr(i) = '1') then
          -- When clear is high then we set Q back to INIT
          if (clr(i) = '1') then
            q(i) <= INIT(i);
          else
            q(i) <= d(i);
          end if;
        end if;
      end if;
    end loop;
  end procedure StickyBit;
  
  ------------------------------------------------------------------------------
  -- One Shot
  --
  -- Detect a desired "EDGE" of D0 and create a single pulse
  ------------------------------------------------------------------------------
  procedure OneShot (
    signal   q      : out std_logic;
    signal   d0     : in  std_logic;
    signal   d1     : in  std_logic;
    signal   rst    : in  std_logic;
    signal   clk    : in  std_logic;
    constant EDGE   : in  std_logic := '1') is

    -- Internal signal to tie into q output
    --signal qV     :       std_logic;
  begin
    if (rising_edge(CLK)) then
        if (rst = '1') then
            q <= '0';
        else
            if (EDGE = '1') then --look for rising edge
                if (d0 = '1' and d1 = '0') then
                    q <= '1';
                else
                    q <= '0';
                end if;
            elsif (EDGE = '0') then --look for falling edge
                if (d0 = '0' and d1 = '1') then
                    q <= '1';
                else
                    q <= '0';
                end if;
            end if;
        end if;
     end if;
  end procedure OneShot;

end package body standard_pack;
                        
