-- multiplier (EPF10K70RC240-4)
--
-- Copyright (C) 1988-2001 Altera Corporation
-- Any megafunction design, and related net list (encrypted or decrypted),
-- support information, device programming or simulation file, and any other
-- associated documentation or information provided by Altera or a partner
-- under Altera's Megafunction Partnership Program may be used only to
-- program PLD devices (but not masked PLD devices) from Altera.  Any other
-- use of such megafunction design, net list, support information, device
-- programming or simulation file, or any other related documentation or
-- information is prohibited for any other purpose, including, but not
-- limited to modification, reverse engineering, de-compiling, or use with
-- any other silicon devices, unless such use is explicitly licensed under
-- a separate agreement with Altera or a megafunction partner.  Title to
-- the intellectual property, including patents, copyrights, trademarks,
-- trade secrets, or maskworks, embodied in any such megafunction design,
-- net list, support information, device programming or simulation file, or
-- any other related documentation or information provided by Altera or a
-- megafunction partner, remains with Altera, the megafunction partner, or
-- their respective licensors.  No other licenses, including any licenses
-- needed under any third party's intellectual property, are provided herein.
--
-- MAX+plus II Version 10.1 RC3 06/12/2001
-- Wed Feb 20 20:53:01 2002

--

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY TRIBUF_multiplier IS
    GENERIC (
        ttri: TIME := 1 ns;
        ttxz: TIME := 1 ns;
        ttzx: TIME := 1 ns);
    PORT (
        in1 : IN std_logic;
        oe  : IN std_logic;
        y   : OUT std_logic);
END TRIBUF_multiplier;

ARCHITECTURE behavior OF TRIBUF_multiplier IS
BEGIN
    PROCESS (in1, oe)
    BEGIN
        IF oe'EVENT THEN
            IF oe = '0' THEN
                y <= TRANSPORT 'Z' AFTER ttxz;
            ELSIF oe = '1' THEN
                y <= TRANSPORT in1 AFTER ttzx;
            END IF;
        ELSIF oe = '1' THEN
            y <= TRANSPORT in1 AFTER ttri;
        ELSIF oe = '0' THEN
            y <= TRANSPORT 'Z' AFTER ttxz;
        END IF;
    END PROCESS;
END behavior;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.tribuf_multiplier;

ENTITY multiplier IS
    PORT (
      x_in : IN std_logic_vector(4 downto 0);
      y_in : IN std_logic_vector(4 downto 0);
      f : OUT std_logic_vector(9 downto 0));
END multiplier;

ARCHITECTURE \EPF10K70RC240-4\ OF multiplier IS

SIGNAL gnd : std_logic;
SIGNAL vcc : std_logic;
SIGNAL
    n_53, n_54, n_55, n_56, n_57, \:1882.OUT\, n_59, n_60, n_61, n_62, n_63,
          n_64, \:1876.OUT\, n_66, n_67, n_68, n_69, n_70, n_71, \:1870.OUT\,
          n_73, n_74, n_75, n_76, n_77, n_78, \:1864.OUT\, n_80, n_81, n_82,
          n_83, n_84, n_85, \:1858.OUT\, n_87, n_88, n_89, n_90, n_91, n_92,
          \:841.OUT\, n_94, n_95, n_96, n_97, n_98, n_99, \:1115.OUT\, n_101,
          n_102, n_103, n_104, n_105, n_106, \:1361.OUT\, n_108, n_109, n_110,
          n_111, n_112, n_113, \:1607.OUT\, n_115, n_116, n_117, n_118, n_119,
          n_120, \:1888.OUT\, n_122, \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\,
          n_124, n_125, n_126, n_127, n_129, \:625.OUT\, n_131, \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\,
          n_133, n_134, \:631.OUT\, n_136, n_137, n_138, n_139, n_140, n_141,
          \:1091.OUT\, n_143, n_144, n_145, n_146, n_147, \:673.OUT\, n_149,
          n_150, n_151, n_152, n_153, n_154, n_155, n_156, n_157, n_158, n_159,
          n_160, n_161, n_162, n_163, \:1343.OUT\, n_165, n_166, n_167, n_168,
          n_169, \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\, n_171, n_172,
          n_173, n_174, n_175, \:667.OUT~NOT\, n_177, n_178, n_179, n_180,
          n_181, n_182, n_183, n_184, n_185, n_186, n_187, n_188, n_189, n_190,
          \:1595.OUT\, n_192, n_193, n_194, n_195, \:637.OUT\, n_197, \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\,
          n_199, n_200, n_201, n_202, n_203, \:661.OUT\, n_205, n_206, n_207,
          n_208, n_209, n_210, n_211, n_212, n_213, n_214, n_215, n_216, n_217,
          n_218, n_219, n_220, n_221, n_222, n_223, \:657.OUT\, n_225, \|lpm_add_sub:1716|addcore:adder|~97~1.OUT\,
          n_227, n_228, n_229, n_230, n_231, n_232, n_233, \|lpm_add_sub:589|addcore:adder|:80.OUT\,
          n_235, n_236, n_237, n_238, n_240, n_242, n_244, n_245, n_246, n_247,
          n_248, n_249, n_250, \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\,
          n_252, n_253, n_254, n_255, \:643.OUT\, n_257, n_258, n_259, n_260,
          \:1601.OUT\, n_262, n_263, n_264, n_265, n_266, n_267, \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\,
          n_269, n_270, n_271, n_272, n_273, n_274, n_275, n_276, n_277, n_278,
          n_279, n_280, \:1085.OUT\, n_282, n_283, n_284, n_285, n_286, n_287,
          n_288, n_289, n_290, n_291, \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\,
          n_293, n_294, n_295, n_296, n_297, n_298, n_299, n_300, n_301, n_302,
          n_303, n_304, \:1337.OUT\, n_306, n_307, n_308, n_309, n_310, n_311,
          n_312, n_313, n_314, n_315, n_316, n_317, n_318, n_319, n_320, n_321,
          n_322, n_323, n_324, n_325, n_326, n_327, n_328, n_329, \:1589.OUT\,
          n_331, n_332, n_333, n_334, n_335, n_336, n_337, n_338, n_339, n_340,
          n_341, n_342, n_343, n_344, n_345, n_346, n_347, n_348, n_349, n_350,
          n_351, n_352, n_353, n_354, n_355, n_356, n_357, n_358, n_359, n_360,
          n_361, n_362, n_363, n_364, n_365, n_366, n_367, n_368, n_369, n_370,
          n_371, n_372, n_373, n_374, n_375, n_376, n_377, n_378, \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\,
          n_380, n_381, n_382, n_383, n_384, n_385, n_386, n_387, n_388, n_389,
          n_390, n_391, \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\, n_393,
          n_394, n_395, n_396, n_397, n_398, n_399, n_400, n_401, n_402, n_403,
          n_404, \~1331~1.OUT\, n_406, n_407, n_408, n_409, \~667~1.OUT\,
          n_411, n_412, n_413, n_414, n_415, n_416, \:1331.OUT\, n_418, n_419,
          n_420, n_421, n_422, n_423, n_424, n_425, n_426, n_427, n_428, n_429,
          n_430, n_431, n_432, n_433, \:1583.OUT\, n_435, n_436, n_437, n_438,
          n_439, n_440, n_441, n_442, n_443, n_444, n_445, n_446, n_447, n_448,
          n_449, n_450, n_451, n_452, n_453, n_454, n_455, n_456, n_457, n_458,
          n_459, n_460, n_461, n_462, n_463, \|lpm_add_sub:589|addcore:adder|:81.OUT\,
          n_465, n_466, n_467, n_468, n_469, n_470, n_471, n_472, n_473, n_474,
          n_475, n_476, n_477, n_478, n_479, n_480, n_481, n_482, n_483, \:1577.OUT\,
          n_485, n_486, n_487, n_488, n_489, n_490, n_491, n_492, n_493, n_494,
          n_495, n_496, n_497, n_498, n_499, n_500, \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\,
          n_502, n_503, n_504, n_505, n_506, n_507, n_508, n_509, n_510, n_511,
          n_512, n_513, n_514, n_515, n_516, n_517, n_518, n_519, n_520, \|lpm_add_sub:589|addcore:adder|:82.OUT\,
          n_522, n_523, n_524, n_525, n_526, n_527, n_528, n_529, n_530, n_531,
          n_532, n_533, n_534, n_535, n_536, n_537, n_538, \|lpm_add_sub:1716|addcore:adder|~101~1.OUT\,
          n_540, n_541, n_542, n_543, n_544, n_545, n_546, n_547, n_548, n_549,
          n_550, n_551, n_552, n_553, n_554, n_555, n_556, n_557, n_558, n_559,
          n_560, n_561, n_562, n_563, n_564, n_565, n_566, n_567, n_568, n_569,
          n_572, n_573, n_574, n_575, n_576, n_577, n_578, n_579, n_580, n_581,
          n_582, n_583, n_584, n_585, n_586, n_587, n_588, n_589, n_590, n_591,
          n_592, n_593, n_594, n_595, n_596, n_597, n_598, n_599, n_600, n_601,
          n_602, n_603, n_604, n_605, n_606, n_607, n_608, n_609, n_610, n_611,
          n_612, n_613, n_614, n_615, n_616, n_617, n_618, n_619, n_620, n_621,
          n_622, n_623, n_624, n_625, n_626, n_627, n_628, n_629, n_630, n_631,
          n_632, n_633, n_634, \|lpm_add_sub:972|addcore:adder|:97.OUT\, n_636,
          n_637, n_638, n_639, n_640, n_641, n_642, n_643, n_644, n_645, n_646,
          n_647, n_648, n_649, n_650, n_651, n_652, n_653, \:1109.OUT\, n_655,
          n_656, n_657, n_658, n_659, n_660, n_661, n_662, n_663, n_664, \:667.OUT\,
          n_667, n_668, n_669, n_670, n_671, n_672, n_673, n_674, n_675, n_676,
          n_677, n_678, n_679, n_680, n_681, n_682, n_683, n_684, n_685, n_686,
          n_687, n_688, n_689, n_690, n_691, n_692, n_693, n_694, n_695, n_696,
          n_697, \|lpm_add_sub:600|addcore:adder|:63.OUT\, n_699, n_700, n_701,
          n_702, n_703, n_704, n_705, n_707, n_708, n_709, n_710, n_711, n_712,
          n_713, n_714, n_715, n_716, n_717, n_718, n_719, \|lpm_add_sub:1218|addcore:adder|:60.OUT\,
          n_721, n_722, n_723, n_724, n_725, n_726, \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\,
          n_728, n_729, n_730, n_731, n_732, n_733, n_734, n_735, n_736, n_737,
          n_738, n_740, n_741, n_742, n_743, n_744, n_745, n_746, n_747, n_748,
          n_749, n_750, n_751, n_752, n_753, n_754, n_755, n_756, n_757, n_758,
          n_759, n_760, n_761, n_762, n_763, n_764, n_765, \|lpm_add_sub:972|addcore:adder|:98.OUT\,
          n_767, n_768, n_769, n_770, n_771, n_772, n_773, n_774, n_775, n_776,
          n_777, n_778, n_779, n_780, n_781, n_782, n_783, n_784, n_785, n_786,
          n_787, n_788, n_789, n_790, n_791, n_792, n_793, n_794, n_795, \:1103.OUT\,
          n_797, n_798, n_799, n_800, n_801, n_802, n_803, n_804, n_805, n_806,
          \:1355.OUT\, n_808, n_809, n_810, n_811, n_812, n_813, n_814, n_815,
          n_816, n_817, n_818, n_819, n_820, n_821, n_822, n_823, n_824, n_825,
          n_826, n_827, n_828, n_829, n_830, n_831, n_832, n_833, n_834, n_835,
          n_836, n_837, n_838, n_839, n_840, n_841, n_842, n_843, n_844, \|lpm_add_sub:589|addcore:adder|:63.OUT\,
          n_846, n_847, n_848, n_849, n_850, n_851, n_852, n_854, n_855, n_856,
          n_857, n_858, n_859, n_860, n_861, n_862, n_863, n_864, n_865, n_866,
          n_867, n_868, n_869, n_870, n_871, n_872, n_873, n_874, n_875, n_876,
          n_877, n_878, n_879, n_880, n_881, n_882, n_883, n_884, n_885, n_886,
          n_887, n_888, n_889, \|lpm_add_sub:972|addcore:adder|:99.OUT\, n_891,
          n_892, n_893, n_894, n_895, n_896, n_897, n_898, n_899, n_900, n_901,
          n_902, n_903, n_904, n_905, n_906, n_907, n_908, n_909, n_910, n_911,
          n_912, n_913, n_914, n_915, n_916, n_917, n_918, n_919, \:1097.OUT\,
          n_921, n_922, n_923, n_924, n_925, n_926, n_927, n_928, n_929, n_930,
          \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\, n_932, n_933, n_934,
          n_935, n_936, n_937, n_938, n_939, n_940, n_941, n_942, n_943, n_944,
          n_945, \:1349.OUT\, n_947, n_948, n_949, n_950, n_951, n_952, n_953,
          n_954, n_955, n_956, n_957, n_958, n_959, n_960, n_961, n_962, n_963,
          n_964, n_965, n_966, n_967, n_968, n_969, n_970, \|lpm_add_sub:1464|addcore:adder|:60.OUT\,
          n_972, n_973, n_974, n_975, n_976, n_977, n_978, n_979, n_980, n_981,
          n_982, n_983, n_984, n_985, n_986, n_987, n_988, n_989, n_990, n_991,
          n_992, n_993, n_994, n_995, n_996, n_997, n_998, n_999, n_1000,
          n_1001, n_1002, n_1003, n_1004, n_1005, n_1006, n_1007, n_1008,
          n_1009, n_1010, n_1011, n_1012, n_1013, n_1014, n_1015, n_1016,
          n_1017, n_1018, n_1019, n_1020, n_1021, n_1022, n_1023, n_1024,
          n_1025, n_1026, n_1027, n_1028, n_1029, n_1030, n_1031, n_1032,
          n_1033, n_1034, n_1035, n_1036, n_1037, n_1038, n_1039, n_1040,
          n_1041, n_1042, n_1043, n_1044, n_1045, n_1046, n_1047, n_1048,
          n_1049, n_1050, n_1051, n_1052, n_1053, n_1054, n_1055, n_1056,
          n_1057, n_1058, n_1059, n_1060 : std_logic;

COMPONENT TRIBUF_multiplier
    GENERIC (ttri, ttxz, ttzx: TIME);
    PORT (in1, oe  : IN std_logic; y : OUT std_logic);
END COMPONENT;

BEGIN
gnd <= '0';
vcc <= '1';

PROCESS(x_in(0), x_in(1), x_in(2), x_in(3), x_in(4), y_in(0), y_in(1), y_in(2), y_in(3),
          y_in(4))
BEGIN
    ASSERT x_in(0) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on x_in(0)"
        SEVERITY Warning;
    ASSERT x_in(1) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on x_in(1)"
        SEVERITY Warning;
    ASSERT x_in(2) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on x_in(2)"
        SEVERITY Warning;
    ASSERT x_in(3) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on x_in(3)"
        SEVERITY Warning;
    ASSERT x_in(4) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on x_in(4)"
        SEVERITY Warning;
    ASSERT y_in(0) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on y_in(0)"
        SEVERITY Warning;
    ASSERT y_in(1) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on y_in(1)"
        SEVERITY Warning;
    ASSERT y_in(2) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on y_in(2)"
        SEVERITY Warning;
    ASSERT y_in(3) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on y_in(3)"
        SEVERITY Warning;
    ASSERT y_in(4) /= 'X' OR Now = 0 ns
        REPORT "Unknown value on y_in(4)"
        SEVERITY Warning;
END PROCESS;

TRIBUF_2: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_53, OE => vcc, Y => f(5));
TRIBUF_4: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_60, OE => vcc, Y => f(6));
TRIBUF_6: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_67, OE => vcc, Y => f(7));
TRIBUF_8: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_74, OE => vcc, Y => f(8));
TRIBUF_10: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_81, OE => vcc, Y => f(9));
TRIBUF_12: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_88, OE => vcc, Y => f(0));
TRIBUF_14: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_95, OE => vcc, Y => f(1));
TRIBUF_16: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_102, OE => vcc, Y => f(2));
TRIBUF_18: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_109, OE => vcc, Y => f(3));
TRIBUF_20: TRIBUF_multiplier
    GENERIC MAP (ttri => 5 ns, ttxz => 6800 ps, ttzx => 6800 ps)
    PORT MAP (IN1 => n_116, OE => vcc, Y => f(4));
DELAY_21: n_53  <= TRANSPORT n_54;
XOR2_22: n_54 <=  n_55  XOR n_59;
OR1_23: n_55 <=  n_56;
AND1_24: n_56 <=  n_57;
DELAY_25: n_57  <= TRANSPORT \:1882.OUT\ AFTER 2500 ps;
AND1_26: n_59 <=  gnd;
DELAY_27: n_60  <= TRANSPORT n_61;
XOR2_28: n_61 <=  n_62  XOR n_66;
OR1_29: n_62 <=  n_63;
AND1_30: n_63 <=  n_64;
DELAY_31: n_64  <= TRANSPORT \:1876.OUT\ AFTER 3400 ps;
AND1_32: n_66 <=  gnd;
DELAY_33: n_67  <= TRANSPORT n_68;
XOR2_34: n_68 <=  n_69  XOR n_73;
OR1_35: n_69 <=  n_70;
AND1_36: n_70 <=  n_71;
DELAY_37: n_71  <= TRANSPORT \:1870.OUT\ AFTER 2800 ps;
AND1_38: n_73 <=  gnd;
DELAY_39: n_74  <= TRANSPORT n_75;
XOR2_40: n_75 <=  n_76  XOR n_80;
OR1_41: n_76 <=  n_77;
AND1_42: n_77 <=  n_78;
DELAY_43: n_78  <= TRANSPORT \:1864.OUT\ AFTER 3 ns;
AND1_44: n_80 <=  gnd;
DELAY_45: n_81  <= TRANSPORT n_82;
XOR2_46: n_82 <=  n_83  XOR n_87;
OR1_47: n_83 <=  n_84;
AND1_48: n_84 <=  n_85;
DELAY_49: n_85  <= TRANSPORT \:1858.OUT\ AFTER 2200 ps;
AND1_50: n_87 <=  gnd;
DELAY_51: n_88  <= TRANSPORT n_89;
XOR2_52: n_89 <=  n_90  XOR n_94;
OR1_53: n_90 <=  n_91;
AND1_54: n_91 <=  n_92;
DELAY_55: n_92  <= TRANSPORT \:841.OUT\ AFTER 2800 ps;
AND1_56: n_94 <=  gnd;
DELAY_57: n_95  <= TRANSPORT n_96;
XOR2_58: n_96 <=  n_97  XOR n_101;
OR1_59: n_97 <=  n_98;
AND1_60: n_98 <=  n_99;
DELAY_61: n_99  <= TRANSPORT \:1115.OUT\ AFTER 2500 ps;
AND1_62: n_101 <=  gnd;
DELAY_63: n_102  <= TRANSPORT n_103;
XOR2_64: n_103 <=  n_104  XOR n_108;
OR1_65: n_104 <=  n_105;
AND1_66: n_105 <=  n_106;
DELAY_67: n_106  <= TRANSPORT \:1361.OUT\ AFTER 2500 ps;
AND1_68: n_108 <=  gnd;
DELAY_69: n_109  <= TRANSPORT n_110;
XOR2_70: n_110 <=  n_111  XOR n_115;
OR1_71: n_111 <=  n_112;
AND1_72: n_112 <=  n_113;
DELAY_73: n_113  <= TRANSPORT \:1607.OUT\ AFTER 2 ns;
AND1_74: n_115 <=  gnd;
DELAY_75: n_116  <= TRANSPORT n_117;
XOR2_76: n_117 <=  n_118  XOR n_122;
OR1_77: n_118 <=  n_119;
AND1_78: n_119 <=  n_120;
DELAY_79: n_120  <= TRANSPORT \:1888.OUT\ AFTER 2200 ps;
AND1_80: n_122 <=  gnd;
DELAY_81: \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\  <= TRANSPORT n_124 AFTER 700 ps;
XOR2_82: n_124 <=  n_125  XOR n_141;
OR3_83: n_125 <=  n_126  OR n_133  OR n_137;
AND3_84: n_126 <=  n_127  AND n_129  AND n_131;
DELAY_85: n_127  <= TRANSPORT y_in(0) AFTER 12300 ps;
DELAY_86: n_129  <= TRANSPORT \:625.OUT\ AFTER 5400 ps;
DELAY_87: n_131  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 4600 ps;
AND2_88: n_133 <=  n_134  AND n_136;
DELAY_89: n_134  <= TRANSPORT \:631.OUT\ AFTER 5400 ps;
DELAY_90: n_136  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 4600 ps;
AND3_91: n_137 <=  n_138  AND n_139  AND n_140;
DELAY_92: n_138  <= TRANSPORT y_in(0) AFTER 12300 ps;
DELAY_93: n_139  <= TRANSPORT \:631.OUT\ AFTER 5400 ps;
DELAY_94: n_140  <= TRANSPORT \:625.OUT\ AFTER 5400 ps;
AND1_95: n_141 <=  gnd;
DELAY_96: \:1091.OUT\  <= TRANSPORT n_143 AFTER 700 ps;
XOR2_97: n_143 <=  n_144  XOR n_163;
OR4_98: n_144 <=  n_145  OR n_150  OR n_154  OR n_159;
AND3_99: n_145 <=  n_146  AND n_147  AND n_149;
DELAY_100: n_146  <= TRANSPORT y_in(0) AFTER 13200 ps;
DELAY_101: n_147  <= TRANSPORT \:673.OUT\ AFTER 5800 ps;
DELAY_102: n_149  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\ AFTER 5200 ps;
AND3_103: n_150 <=  n_151  AND n_152  AND n_153;
INV_104: n_151  <= TRANSPORT NOT \:625.OUT\ AFTER 6100 ps;
DELAY_105: n_152  <= TRANSPORT \:673.OUT\ AFTER 5800 ps;
DELAY_106: n_153  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\ AFTER 5200 ps;
AND4_107: n_154 <=  n_155  AND n_156  AND n_157  AND n_158;
INV_108: n_155  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\ AFTER 5200 ps;
INV_109: n_156  <= TRANSPORT NOT y_in(0) AFTER 13200 ps;
DELAY_110: n_157  <= TRANSPORT \:673.OUT\ AFTER 5800 ps;
DELAY_111: n_158  <= TRANSPORT \:625.OUT\ AFTER 6100 ps;
AND3_112: n_159 <=  n_160  AND n_161  AND n_162;
INV_113: n_160  <= TRANSPORT NOT \:673.OUT\ AFTER 5800 ps;
DELAY_114: n_161  <= TRANSPORT y_in(0) AFTER 13200 ps;
DELAY_115: n_162  <= TRANSPORT \:625.OUT\ AFTER 6100 ps;
AND1_116: n_163 <=  gnd;
DELAY_117: \:1343.OUT\  <= TRANSPORT n_165 AFTER 700 ps;
XOR2_118: n_165 <=  n_166  XOR n_190;
OR5_119: n_166 <=  n_167  OR n_172  OR n_178  OR n_182  OR n_187;
AND3_120: n_167 <=  n_168  AND n_169  AND n_171;
DELAY_121: n_168  <= TRANSPORT \:631.OUT\ AFTER 6400 ps;
DELAY_122: n_169  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
DELAY_123: n_171  <= TRANSPORT \:1091.OUT\ AFTER 2500 ps;
AND4_124: n_172 <=  n_173  AND n_174  AND n_175  AND n_177;
INV_125: n_173  <= TRANSPORT NOT \:1091.OUT\ AFTER 2500 ps;
INV_126: n_174  <= TRANSPORT NOT \:631.OUT\ AFTER 6400 ps;
INV_127: n_175  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_128: n_177  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
AND3_129: n_178 <=  n_179  AND n_180  AND n_181;
INV_130: n_179  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
INV_131: n_180  <= TRANSPORT NOT \:631.OUT\ AFTER 6400 ps;
DELAY_132: n_181  <= TRANSPORT \:1091.OUT\ AFTER 2500 ps;
AND4_133: n_182 <=  n_183  AND n_184  AND n_185  AND n_186;
INV_134: n_183  <= TRANSPORT NOT \:1091.OUT\ AFTER 2500 ps;
INV_135: n_184  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
INV_136: n_185  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_137: n_186  <= TRANSPORT \:631.OUT\ AFTER 6400 ps;
AND2_138: n_187 <=  n_188  AND n_189;
DELAY_139: n_188  <= TRANSPORT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_140: n_189  <= TRANSPORT \:1091.OUT\ AFTER 2500 ps;
AND1_141: n_190 <=  gnd;
DELAY_142: \:1595.OUT\  <= TRANSPORT n_192 AFTER 700 ps;
XOR2_143: n_192 <=  n_193  XOR n_218;
OR5_144: n_193 <=  n_194  OR n_200  OR n_206  OR n_210  OR n_215;
AND3_145: n_194 <=  n_195  AND n_197  AND n_199;
DELAY_146: n_195  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_147: n_197  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_148: n_199  <= TRANSPORT \:1343.OUT\ AFTER 5100 ps;
AND4_149: n_200 <=  n_201  AND n_202  AND n_203  AND n_205;
INV_150: n_201  <= TRANSPORT NOT \:1343.OUT\ AFTER 5100 ps;
INV_151: n_202  <= TRANSPORT NOT \:637.OUT\ AFTER 5100 ps;
DELAY_152: n_203  <= TRANSPORT \:661.OUT\ AFTER 5400 ps;
DELAY_153: n_205  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND3_154: n_206 <=  n_207  AND n_208  AND n_209;
INV_155: n_207  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
INV_156: n_208  <= TRANSPORT NOT \:637.OUT\ AFTER 5100 ps;
DELAY_157: n_209  <= TRANSPORT \:1343.OUT\ AFTER 5100 ps;
AND4_158: n_210 <=  n_211  AND n_212  AND n_213  AND n_214;
INV_159: n_211  <= TRANSPORT NOT \:1343.OUT\ AFTER 5100 ps;
INV_160: n_212  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_161: n_213  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_162: n_214  <= TRANSPORT \:661.OUT\ AFTER 5400 ps;
AND2_163: n_215 <=  n_216  AND n_217;
INV_164: n_216  <= TRANSPORT NOT \:661.OUT\ AFTER 5400 ps;
DELAY_165: n_217  <= TRANSPORT \:1343.OUT\ AFTER 5100 ps;
AND1_166: n_218 <=  gnd;
DELAY_167: \:1882.OUT\  <= TRANSPORT n_219 AFTER 700 ps;
XOR2_168: n_219 <=  n_220  XOR n_233;
OR3_169: n_220 <=  n_221  OR n_227  OR n_230;
AND3_170: n_221 <=  n_222  AND n_223  AND n_225;
INV_171: n_222  <= TRANSPORT NOT \:1595.OUT\ AFTER 4600 ps;
DELAY_172: n_223  <= TRANSPORT \:657.OUT\ AFTER 5600 ps;
DELAY_173: n_225  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|~97~1.OUT\ AFTER 2500 ps;
AND2_174: n_227 <=  n_228  AND n_229;
INV_175: n_228  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|~97~1.OUT\ AFTER 2500 ps;
DELAY_176: n_229  <= TRANSPORT \:1595.OUT\ AFTER 4600 ps;
AND2_177: n_230 <=  n_231  AND n_232;
INV_178: n_231  <= TRANSPORT NOT \:657.OUT\ AFTER 5600 ps;
DELAY_179: n_232  <= TRANSPORT \:1595.OUT\ AFTER 4600 ps;
AND1_180: n_233 <=  gnd;
DELAY_181: \|lpm_add_sub:589|addcore:adder|:80.OUT\  <= TRANSPORT n_235 AFTER 700 ps;
XOR2_182: n_235 <=  n_236  XOR n_250;
OR3_183: n_236 <=  n_237  OR n_244  OR n_247;
AND3_184: n_237 <=  n_238  AND n_240  AND n_242;
INV_185: n_238  <= TRANSPORT NOT x_in(1) AFTER 12100 ps;
INV_186: n_240  <= TRANSPORT NOT x_in(0) AFTER 12400 ps;
DELAY_187: n_242  <= TRANSPORT x_in(2) AFTER 11800 ps;
AND2_188: n_244 <=  n_245  AND n_246;
INV_189: n_245  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
DELAY_190: n_246  <= TRANSPORT x_in(1) AFTER 12100 ps;
AND2_191: n_247 <=  n_248  AND n_249;
INV_192: n_248  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
DELAY_193: n_249  <= TRANSPORT x_in(0) AFTER 12400 ps;
AND1_194: n_250 <=  gnd;
DELAY_195: \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\  <= TRANSPORT n_252 AFTER 700 ps;
XOR2_196: n_252 <=  n_253  XOR n_267;
OR3_197: n_253 <=  n_254  OR n_258  OR n_263;
AND2_198: n_254 <=  n_255  AND n_257;
DELAY_199: n_255  <= TRANSPORT \:643.OUT\ AFTER 5200 ps;
DELAY_200: n_257  <= TRANSPORT \:1595.OUT\ AFTER 2500 ps;
AND3_201: n_258 <=  n_259  AND n_260  AND n_262;
DELAY_202: n_259  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_203: n_260  <= TRANSPORT \:1601.OUT\ AFTER 4700 ps;
DELAY_204: n_262  <= TRANSPORT \:1595.OUT\ AFTER 2500 ps;
AND3_205: n_263 <=  n_264  AND n_265  AND n_266;
DELAY_206: n_264  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_207: n_265  <= TRANSPORT \:643.OUT\ AFTER 5200 ps;
DELAY_208: n_266  <= TRANSPORT \:1601.OUT\ AFTER 4700 ps;
AND1_209: n_267 <=  gnd;
DELAY_210: \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\  <= TRANSPORT n_269 AFTER 700 ps;
XOR2_211: n_269 <=  n_270  XOR n_280;
OR3_212: n_270 <=  n_271  OR n_274  OR n_277;
AND2_213: n_271 <=  n_272  AND n_273;
DELAY_214: n_272  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_215: n_273  <= TRANSPORT \:1343.OUT\ AFTER 5100 ps;
AND2_216: n_274 <=  n_275  AND n_276;
DELAY_217: n_275  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_218: n_276  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND2_219: n_277 <=  n_278  AND n_279;
DELAY_220: n_278  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_221: n_279  <= TRANSPORT \:1343.OUT\ AFTER 5100 ps;
AND1_222: n_280 <=  gnd;
DELAY_223: \:1085.OUT\  <= TRANSPORT n_282 AFTER 700 ps;
XOR2_224: n_282 <=  n_283  XOR n_291;
OR2_225: n_283 <=  n_284  OR n_287;
AND2_226: n_284 <=  n_285  AND n_286;
DELAY_227: n_285  <= TRANSPORT y_in(0) AFTER 13200 ps;
DELAY_228: n_286  <= TRANSPORT \:625.OUT\ AFTER 6100 ps;
AND3_229: n_287 <=  n_288  AND n_289  AND n_290;
INV_230: n_288  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry3.OUT\ AFTER 5200 ps;
DELAY_231: n_289  <= TRANSPORT \:673.OUT\ AFTER 5800 ps;
DELAY_232: n_290  <= TRANSPORT \:625.OUT\ AFTER 6100 ps;
AND1_233: n_291 <=  gnd;
DELAY_234: \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\  <= TRANSPORT n_293 AFTER 700 ps;
XOR2_235: n_293 <=  n_294  XOR n_304;
OR3_236: n_294 <=  n_295  OR n_298  OR n_301;
AND2_237: n_295 <=  n_296  AND n_297;
DELAY_238: n_296  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
DELAY_239: n_297  <= TRANSPORT \:1091.OUT\ AFTER 2500 ps;
AND2_240: n_298 <=  n_299  AND n_300;
DELAY_241: n_299  <= TRANSPORT \:631.OUT\ AFTER 6400 ps;
DELAY_242: n_300  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\ AFTER 4800 ps;
AND2_243: n_301 <=  n_302  AND n_303;
DELAY_244: n_302  <= TRANSPORT \:631.OUT\ AFTER 6400 ps;
DELAY_245: n_303  <= TRANSPORT \:1091.OUT\ AFTER 2500 ps;
AND1_246: n_304 <=  gnd;
DELAY_247: \:1337.OUT\  <= TRANSPORT n_306 AFTER 700 ps;
XOR2_248: n_306 <=  n_307  XOR n_329;
OR5_249: n_307 <=  n_308  OR n_311  OR n_315  OR n_320  OR n_324;
AND2_250: n_308 <=  n_309  AND n_310;
DELAY_251: n_309  <= TRANSPORT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_252: n_310  <= TRANSPORT \:1085.OUT\ AFTER 2500 ps;
AND3_253: n_311 <=  n_312  AND n_313  AND n_314;
DELAY_254: n_312  <= TRANSPORT \:625.OUT\ AFTER 6400 ps;
DELAY_255: n_313  <= TRANSPORT \:1085.OUT\ AFTER 2500 ps;
DELAY_256: n_314  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND4_257: n_315 <=  n_316  AND n_317  AND n_318  AND n_319;
INV_258: n_316  <= TRANSPORT NOT \:1085.OUT\ AFTER 2500 ps;
INV_259: n_317  <= TRANSPORT NOT \:625.OUT\ AFTER 6400 ps;
INV_260: n_318  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_261: n_319  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND3_262: n_320 <=  n_321  AND n_322  AND n_323;
INV_263: n_321  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
INV_264: n_322  <= TRANSPORT NOT \:625.OUT\ AFTER 6400 ps;
DELAY_265: n_323  <= TRANSPORT \:1085.OUT\ AFTER 2500 ps;
AND4_266: n_324 <=  n_325  AND n_326  AND n_327  AND n_328;
INV_267: n_325  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
INV_268: n_326  <= TRANSPORT NOT \:1085.OUT\ AFTER 2500 ps;
INV_269: n_327  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_270: n_328  <= TRANSPORT \:625.OUT\ AFTER 6400 ps;
AND1_271: n_329 <=  gnd;
DELAY_272: \:1589.OUT\  <= TRANSPORT n_331 AFTER 700 ps;
XOR2_273: n_331 <=  n_332  XOR n_354;
OR5_274: n_332 <=  n_333  OR n_337  OR n_342  OR n_346  OR n_351;
AND3_275: n_333 <=  n_334  AND n_335  AND n_336;
DELAY_276: n_334  <= TRANSPORT \:631.OUT\ AFTER 5400 ps;
DELAY_277: n_335  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 2500 ps;
DELAY_278: n_336  <= TRANSPORT \:1337.OUT\ AFTER 4800 ps;
AND4_279: n_337 <=  n_338  AND n_339  AND n_340  AND n_341;
INV_280: n_338  <= TRANSPORT NOT \:1337.OUT\ AFTER 4800 ps;
INV_281: n_339  <= TRANSPORT NOT \:631.OUT\ AFTER 5400 ps;
DELAY_282: n_340  <= TRANSPORT \:661.OUT\ AFTER 5400 ps;
DELAY_283: n_341  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 2500 ps;
AND3_284: n_342 <=  n_343  AND n_344  AND n_345;
INV_285: n_343  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 2500 ps;
INV_286: n_344  <= TRANSPORT NOT \:631.OUT\ AFTER 5400 ps;
DELAY_287: n_345  <= TRANSPORT \:1337.OUT\ AFTER 4800 ps;
AND4_288: n_346 <=  n_347  AND n_348  AND n_349  AND n_350;
INV_289: n_347  <= TRANSPORT NOT \:1337.OUT\ AFTER 4800 ps;
INV_290: n_348  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 2500 ps;
DELAY_291: n_349  <= TRANSPORT \:661.OUT\ AFTER 5400 ps;
DELAY_292: n_350  <= TRANSPORT \:631.OUT\ AFTER 5400 ps;
AND2_293: n_351 <=  n_352  AND n_353;
INV_294: n_352  <= TRANSPORT NOT \:661.OUT\ AFTER 5400 ps;
DELAY_295: n_353  <= TRANSPORT \:1337.OUT\ AFTER 4800 ps;
AND1_296: n_354 <=  gnd;
DELAY_297: \:1876.OUT\  <= TRANSPORT n_355 AFTER 700 ps;
XOR2_298: n_355 <=  n_356  XOR n_378;
OR5_299: n_356 <=  n_357  OR n_362  OR n_367  OR n_371  OR n_375;
AND4_300: n_357 <=  n_358  AND n_359  AND n_360  AND n_361;
INV_301: n_358  <= TRANSPORT NOT \:1589.OUT\ AFTER 2200 ps;
INV_302: n_359  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:80.OUT\ AFTER 4900 ps;
DELAY_303: n_360  <= TRANSPORT \:657.OUT\ AFTER 5400 ps;
DELAY_304: n_361  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND4_305: n_362 <=  n_363  AND n_364  AND n_365  AND n_366;
INV_306: n_363  <= TRANSPORT NOT \:1589.OUT\ AFTER 2200 ps;
INV_307: n_364  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_308: n_365  <= TRANSPORT \:657.OUT\ AFTER 5400 ps;
DELAY_309: n_366  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:80.OUT\ AFTER 4900 ps;
AND3_310: n_367 <=  n_368  AND n_369  AND n_370;
DELAY_311: n_368  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:80.OUT\ AFTER 4900 ps;
DELAY_312: n_369  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_313: n_370  <= TRANSPORT \:1589.OUT\ AFTER 2200 ps;
AND3_314: n_371 <=  n_372  AND n_373  AND n_374;
INV_315: n_372  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
INV_316: n_373  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:80.OUT\ AFTER 4900 ps;
DELAY_317: n_374  <= TRANSPORT \:1589.OUT\ AFTER 2200 ps;
AND2_318: n_375 <=  n_376  AND n_377;
INV_319: n_376  <= TRANSPORT NOT \:657.OUT\ AFTER 5400 ps;
DELAY_320: n_377  <= TRANSPORT \:1589.OUT\ AFTER 2200 ps;
AND1_321: n_378 <=  gnd;
DELAY_322: \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\  <= TRANSPORT n_380 AFTER 700 ps;
XOR2_323: n_380 <=  n_381  XOR n_391;
OR3_324: n_381 <=  n_382  OR n_385  OR n_388;
AND2_325: n_382 <=  n_383  AND n_384;
DELAY_326: n_383  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
DELAY_327: n_384  <= TRANSPORT \:1589.OUT\ AFTER 2500 ps;
AND2_328: n_385 <=  n_386  AND n_387;
DELAY_329: n_386  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_330: n_387  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND2_331: n_388 <=  n_389  AND n_390;
DELAY_332: n_389  <= TRANSPORT \:637.OUT\ AFTER 5100 ps;
DELAY_333: n_390  <= TRANSPORT \:1589.OUT\ AFTER 2500 ps;
AND1_334: n_391 <=  gnd;
DELAY_335: \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\  <= TRANSPORT n_393 AFTER 700 ps;
XOR2_336: n_393 <=  n_394  XOR n_404;
OR3_337: n_394 <=  n_395  OR n_398  OR n_401;
AND2_338: n_395 <=  n_396  AND n_397;
DELAY_339: n_396  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 5100 ps;
DELAY_340: n_397  <= TRANSPORT \:1337.OUT\ AFTER 4300 ps;
AND2_341: n_398 <=  n_399  AND n_400;
DELAY_342: n_399  <= TRANSPORT \:631.OUT\ AFTER 6300 ps;
DELAY_343: n_400  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry2.OUT\ AFTER 5100 ps;
AND2_344: n_401 <=  n_402  AND n_403;
DELAY_345: n_402  <= TRANSPORT \:631.OUT\ AFTER 6300 ps;
DELAY_346: n_403  <= TRANSPORT \:1337.OUT\ AFTER 4300 ps;
AND1_347: n_404 <=  gnd;
DELAY_348: \~1331~1.OUT\  <= TRANSPORT n_406 AFTER 700 ps;
XOR2_349: n_406 <=  n_407  XOR n_409;
OR1_350: n_407 <=  n_408;
AND1_351: n_408 <=  vcc;
AND1_352: n_409 <=  gnd;
DELAY_353: \~667~1.OUT\  <= TRANSPORT n_411 AFTER 700 ps;
XOR2_354: n_411 <=  n_412  XOR n_416;
OR1_355: n_412 <=  n_413;
AND2_356: n_413 <=  n_414  AND n_415;
INV_357: n_414  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
DELAY_358: n_415  <= TRANSPORT \:625.OUT\ AFTER 6400 ps;
AND1_359: n_416 <=  gnd;
DELAY_360: \:1331.OUT\  <= TRANSPORT n_418 AFTER 700 ps;
XOR2_361: n_418 <=  n_419  XOR n_433;
OR4_362: n_419 <=  n_420  OR n_424  OR n_427  OR n_430;
AND3_363: n_420 <=  n_421  AND n_422  AND n_423;
INV_364: n_421  <= TRANSPORT NOT \~1331~1.OUT\ AFTER 2500 ps;
INV_365: n_422  <= TRANSPORT NOT \:1085.OUT\ AFTER 2500 ps;
INV_366: n_423  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
AND2_367: n_424 <=  n_425  AND n_426;
DELAY_368: n_425  <= TRANSPORT \:1085.OUT\ AFTER 2500 ps;
DELAY_369: n_426  <= TRANSPORT \~1331~1.OUT\ AFTER 2500 ps;
AND2_370: n_427 <=  n_428  AND n_429;
INV_371: n_428  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_372: n_429  <= TRANSPORT \~667~1.OUT\ AFTER 2200 ps;
AND2_373: n_430 <=  n_431  AND n_432;
DELAY_374: n_431  <= TRANSPORT \:667.OUT~NOT\ AFTER 6 ns;
DELAY_375: n_432  <= TRANSPORT \:1085.OUT\ AFTER 2500 ps;
AND1_376: n_433 <=  gnd;
DELAY_377: \:1583.OUT\  <= TRANSPORT n_435 AFTER 700 ps;
XOR2_378: n_435 <=  n_436  XOR n_458;
OR5_379: n_436 <=  n_437  OR n_441  OR n_446  OR n_450  OR n_455;
AND3_380: n_437 <=  n_438  AND n_439  AND n_440;
INV_381: n_438  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
INV_382: n_439  <= TRANSPORT NOT \:625.OUT\ AFTER 6300 ps;
DELAY_383: n_440  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND4_384: n_441 <=  n_442  AND n_443  AND n_444  AND n_445;
INV_385: n_442  <= TRANSPORT NOT \:1331.OUT\ AFTER 4900 ps;
INV_386: n_443  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
DELAY_387: n_444  <= TRANSPORT \:661.OUT\ AFTER 5200 ps;
DELAY_388: n_445  <= TRANSPORT \:625.OUT\ AFTER 6300 ps;
AND3_389: n_446 <=  n_447  AND n_448  AND n_449;
DELAY_390: n_447  <= TRANSPORT \:625.OUT\ AFTER 6300 ps;
DELAY_391: n_448  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
DELAY_392: n_449  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND4_393: n_450 <=  n_451  AND n_452  AND n_453  AND n_454;
INV_394: n_451  <= TRANSPORT NOT \:1331.OUT\ AFTER 4900 ps;
INV_395: n_452  <= TRANSPORT NOT \:625.OUT\ AFTER 6300 ps;
DELAY_396: n_453  <= TRANSPORT \:661.OUT\ AFTER 5200 ps;
DELAY_397: n_454  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND2_398: n_455 <=  n_456  AND n_457;
INV_399: n_456  <= TRANSPORT NOT \:661.OUT\ AFTER 5200 ps;
DELAY_400: n_457  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND1_401: n_458 <=  gnd;
DELAY_402: \:1870.OUT\  <= TRANSPORT n_459 AFTER 700 ps;
XOR2_403: n_459 <=  n_460  XOR n_483;
OR5_404: n_460 <=  n_461  OR n_467  OR n_472  OR n_476  OR n_480;
AND4_405: n_461 <=  n_462  AND n_463  AND n_465  AND n_466;
INV_406: n_462  <= TRANSPORT NOT \:1583.OUT\ AFTER 2200 ps;
INV_407: n_463  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:81.OUT\ AFTER 5300 ps;
DELAY_408: n_465  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
DELAY_409: n_466  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
AND4_410: n_467 <=  n_468  AND n_469  AND n_470  AND n_471;
INV_411: n_468  <= TRANSPORT NOT \:1583.OUT\ AFTER 2200 ps;
INV_412: n_469  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
DELAY_413: n_470  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:81.OUT\ AFTER 5300 ps;
DELAY_414: n_471  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
AND3_415: n_472 <=  n_473  AND n_474  AND n_475;
DELAY_416: n_473  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:81.OUT\ AFTER 5300 ps;
DELAY_417: n_474  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
DELAY_418: n_475  <= TRANSPORT \:1583.OUT\ AFTER 2200 ps;
AND3_419: n_476 <=  n_477  AND n_478  AND n_479;
INV_420: n_477  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
INV_421: n_478  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:81.OUT\ AFTER 5300 ps;
DELAY_422: n_479  <= TRANSPORT \:1583.OUT\ AFTER 2200 ps;
AND2_423: n_480 <=  n_481  AND n_482;
INV_424: n_481  <= TRANSPORT NOT \:657.OUT\ AFTER 5200 ps;
DELAY_425: n_482  <= TRANSPORT \:1583.OUT\ AFTER 2200 ps;
AND1_426: n_483 <=  gnd;
DELAY_427: \:1577.OUT\  <= TRANSPORT n_485 AFTER 700 ps;
XOR2_428: n_485 <=  n_486  XOR n_500;
OR4_429: n_486 <=  n_487  OR n_490  OR n_493  OR n_497;
AND2_430: n_487 <=  n_488  AND n_489;
INV_431: n_488  <= TRANSPORT NOT \:661.OUT\ AFTER 5200 ps;
DELAY_432: n_489  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND2_433: n_490 <=  n_491  AND n_492;
INV_434: n_491  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
DELAY_435: n_492  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND3_436: n_493 <=  n_494  AND n_495  AND n_496;
INV_437: n_494  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
DELAY_438: n_495  <= TRANSPORT \:661.OUT\ AFTER 5200 ps;
DELAY_439: n_496  <= TRANSPORT \:625.OUT\ AFTER 6300 ps;
AND2_440: n_497 <=  n_498  AND n_499;
DELAY_441: n_498  <= TRANSPORT \:625.OUT\ AFTER 6300 ps;
DELAY_442: n_499  <= TRANSPORT \:1331.OUT\ AFTER 4900 ps;
AND1_443: n_500 <=  gnd;
DELAY_444: \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\  <= TRANSPORT n_502 AFTER 700 ps;
XOR2_445: n_502 <=  n_503  XOR n_513;
OR3_446: n_503 <=  n_504  OR n_507  OR n_510;
AND2_447: n_504 <=  n_505  AND n_506;
DELAY_448: n_505  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
DELAY_449: n_506  <= TRANSPORT \:1583.OUT\ AFTER 2200 ps;
AND2_450: n_507 <=  n_508  AND n_509;
DELAY_451: n_508  <= TRANSPORT \:631.OUT\ AFTER 6300 ps;
DELAY_452: n_509  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry2.OUT\ AFTER 5200 ps;
AND2_453: n_510 <=  n_511  AND n_512;
DELAY_454: n_511  <= TRANSPORT \:631.OUT\ AFTER 6300 ps;
DELAY_455: n_512  <= TRANSPORT \:1583.OUT\ AFTER 2200 ps;
AND1_456: n_513 <=  gnd;
DELAY_457: \:1864.OUT\  <= TRANSPORT n_514 AFTER 700 ps;
XOR2_458: n_514 <=  n_515  XOR n_538;
OR5_459: n_515 <=  n_516  OR n_519  OR n_524  OR n_529  OR n_533;
AND2_460: n_516 <=  n_517  AND n_518;
INV_461: n_517  <= TRANSPORT NOT \:657.OUT\ AFTER 5200 ps;
DELAY_462: n_518  <= TRANSPORT \:1577.OUT\ AFTER 2500 ps;
AND3_463: n_519 <=  n_520  AND n_522  AND n_523;
DELAY_464: n_520  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_465: n_522  <= TRANSPORT \:1577.OUT\ AFTER 2500 ps;
DELAY_466: n_523  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND4_467: n_524 <=  n_525  AND n_526  AND n_527  AND n_528;
INV_468: n_525  <= TRANSPORT NOT \:1577.OUT\ AFTER 2500 ps;
INV_469: n_526  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_470: n_527  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
DELAY_471: n_528  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND3_472: n_529 <=  n_530  AND n_531  AND n_532;
INV_473: n_530  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
INV_474: n_531  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_475: n_532  <= TRANSPORT \:1577.OUT\ AFTER 2500 ps;
AND4_476: n_533 <=  n_534  AND n_535  AND n_536  AND n_537;
INV_477: n_534  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
INV_478: n_535  <= TRANSPORT NOT \:1577.OUT\ AFTER 2500 ps;
DELAY_479: n_536  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_480: n_537  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
AND1_481: n_538 <=  gnd;
DELAY_482: \|lpm_add_sub:1716|addcore:adder|~101~1.OUT\  <= TRANSPORT n_540 AFTER 700 ps;
XOR2_483: n_540 <=  n_541  XOR n_549;
OR2_484: n_541 <=  n_542  OR n_546;
AND3_485: n_542 <=  n_543  AND n_544  AND n_545;
INV_486: n_543  <= TRANSPORT NOT \:1577.OUT\ AFTER 2500 ps;
DELAY_487: n_544  <= TRANSPORT \:625.OUT\ AFTER 6300 ps;
DELAY_488: n_545  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|pcarry3.OUT\ AFTER 2200 ps;
AND2_489: n_546 <=  n_547  AND n_548;
INV_490: n_547  <= TRANSPORT NOT \:625.OUT\ AFTER 6300 ps;
DELAY_491: n_548  <= TRANSPORT \:1577.OUT\ AFTER 2500 ps;
AND1_492: n_549 <=  gnd;
DELAY_493: \:1858.OUT\  <= TRANSPORT n_550 AFTER 700 ps;
XOR2_494: n_550 <=  n_551  XOR n_563;
OR3_495: n_551 <=  n_552  OR n_556  OR n_560;
AND3_496: n_552 <=  n_553  AND n_554  AND n_555;
INV_497: n_553  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_498: n_554  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
DELAY_499: n_555  <= TRANSPORT \|lpm_add_sub:1716|addcore:adder|~101~1.OUT\ AFTER 2200 ps;
AND3_500: n_556 <=  n_557  AND n_558  AND n_559;
INV_501: n_557  <= TRANSPORT NOT \|lpm_add_sub:1716|addcore:adder|~101~1.OUT\ AFTER 2200 ps;
DELAY_502: n_558  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 5300 ps;
DELAY_503: n_559  <= TRANSPORT \:657.OUT\ AFTER 5200 ps;
AND2_504: n_560 <=  n_561  AND n_562;
INV_505: n_561  <= TRANSPORT NOT \:657.OUT\ AFTER 5200 ps;
DELAY_506: n_562  <= TRANSPORT \:1577.OUT\ AFTER 2500 ps;
AND1_507: n_563 <=  gnd;
DELAY_508: \:841.OUT\  <= TRANSPORT n_564 AFTER 700 ps;
XOR2_509: n_564 <=  n_565  XOR n_569;
OR1_510: n_565 <=  n_566;
AND2_511: n_566 <=  n_567  AND n_568;
DELAY_512: n_567  <= TRANSPORT y_in(0) AFTER 12 ns;
DELAY_513: n_568  <= TRANSPORT x_in(0) AFTER 11700 ps;
AND1_514: n_569 <=  gnd;
DELAY_515: \:673.OUT\  <= TRANSPORT n_572 AFTER 700 ps;
XOR2_516: n_572 <=  n_573  XOR n_584;
OR3_517: n_573 <=  n_574  OR n_577  OR n_581;
AND2_518: n_574 <=  n_575  AND n_576;
INV_519: n_575  <= TRANSPORT NOT y_in(4) AFTER 11400 ps;
DELAY_520: n_576  <= TRANSPORT y_in(1) AFTER 11600 ps;
AND3_521: n_577 <=  n_578  AND n_579  AND n_580;
INV_522: n_578  <= TRANSPORT NOT y_in(1) AFTER 11600 ps;
DELAY_523: n_579  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_524: n_580  <= TRANSPORT y_in(4) AFTER 11400 ps;
AND2_525: n_581 <=  n_582  AND n_583;
INV_526: n_582  <= TRANSPORT NOT y_in(0) AFTER 12400 ps;
DELAY_527: n_583  <= TRANSPORT y_in(1) AFTER 11600 ps;
AND1_528: n_584 <=  gnd;
DELAY_529: \:643.OUT\  <= TRANSPORT n_585 AFTER 700 ps;
XOR2_530: n_585 <=  n_586  XOR n_597;
OR3_531: n_586 <=  n_587  OR n_590  OR n_594;
AND2_532: n_587 <=  n_588  AND n_589;
INV_533: n_588  <= TRANSPORT NOT y_in(4) AFTER 11800 ps;
DELAY_534: n_589  <= TRANSPORT x_in(1) AFTER 12100 ps;
AND3_535: n_590 <=  n_591  AND n_592  AND n_593;
INV_536: n_591  <= TRANSPORT NOT x_in(1) AFTER 12100 ps;
DELAY_537: n_592  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_538: n_593  <= TRANSPORT y_in(4) AFTER 11800 ps;
AND2_539: n_594 <=  n_595  AND n_596;
INV_540: n_595  <= TRANSPORT NOT x_in(0) AFTER 12700 ps;
DELAY_541: n_596  <= TRANSPORT x_in(1) AFTER 12100 ps;
AND1_542: n_597 <=  gnd;
DELAY_543: \:1115.OUT\  <= TRANSPORT n_598 AFTER 700 ps;
XOR2_544: n_598 <=  n_599  XOR n_616;
OR4_545: n_599 <=  n_600  OR n_604  OR n_608  OR n_612;
AND3_546: n_600 <=  n_601  AND n_602  AND n_603;
INV_547: n_601  <= TRANSPORT NOT \:673.OUT\ AFTER 2500 ps;
DELAY_548: n_602  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_549: n_603  <= TRANSPORT \:643.OUT\ AFTER 5 ns;
AND3_550: n_604 <=  n_605  AND n_606  AND n_607;
INV_551: n_605  <= TRANSPORT NOT x_in(0) AFTER 12300 ps;
DELAY_552: n_606  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_553: n_607  <= TRANSPORT \:643.OUT\ AFTER 5 ns;
AND3_554: n_608 <=  n_609  AND n_610  AND n_611;
INV_555: n_609  <= TRANSPORT NOT \:643.OUT\ AFTER 5 ns;
DELAY_556: n_610  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_557: n_611  <= TRANSPORT \:673.OUT\ AFTER 2500 ps;
AND3_558: n_612 <=  n_613  AND n_614  AND n_615;
INV_559: n_613  <= TRANSPORT NOT y_in(0) AFTER 12400 ps;
DELAY_560: n_614  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_561: n_615  <= TRANSPORT \:673.OUT\ AFTER 2500 ps;
AND1_562: n_616 <=  gnd;
DELAY_563: \:637.OUT\  <= TRANSPORT n_617 AFTER 700 ps;
XOR2_564: n_617 <=  n_618  XOR n_634;
OR4_565: n_618 <=  n_619  OR n_622  OR n_626  OR n_630;
AND2_566: n_619 <=  n_620  AND n_621;
INV_567: n_620  <= TRANSPORT NOT y_in(4) AFTER 11800 ps;
DELAY_568: n_621  <= TRANSPORT x_in(2) AFTER 11800 ps;
AND3_569: n_622 <=  n_623  AND n_624  AND n_625;
INV_570: n_623  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
DELAY_571: n_624  <= TRANSPORT y_in(4) AFTER 11800 ps;
DELAY_572: n_625  <= TRANSPORT x_in(1) AFTER 12100 ps;
AND3_573: n_626 <=  n_627  AND n_628  AND n_629;
INV_574: n_627  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
DELAY_575: n_628  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_576: n_629  <= TRANSPORT y_in(4) AFTER 11800 ps;
AND3_577: n_630 <=  n_631  AND n_632  AND n_633;
INV_578: n_631  <= TRANSPORT NOT x_in(1) AFTER 12100 ps;
INV_579: n_632  <= TRANSPORT NOT x_in(0) AFTER 12700 ps;
DELAY_580: n_633  <= TRANSPORT x_in(2) AFTER 11800 ps;
AND1_581: n_634 <=  gnd;
DELAY_582: \|lpm_add_sub:972|addcore:adder|:97.OUT\  <= TRANSPORT n_636 AFTER 700 ps;
XOR2_583: n_636 <=  n_637  XOR n_653;
OR4_584: n_637 <=  n_638  OR n_642  OR n_646  OR n_649;
AND3_585: n_638 <=  n_639  AND n_640  AND n_641;
DELAY_586: n_639  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_587: n_640  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_588: n_641  <= TRANSPORT \:637.OUT\ AFTER 4800 ps;
AND3_589: n_642 <=  n_643  AND n_644  AND n_645;
INV_590: n_643  <= TRANSPORT NOT \:643.OUT\ AFTER 5300 ps;
DELAY_591: n_644  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_592: n_645  <= TRANSPORT \:637.OUT\ AFTER 4800 ps;
AND2_593: n_646 <=  n_647  AND n_648;
INV_594: n_647  <= TRANSPORT NOT y_in(0) AFTER 12400 ps;
DELAY_595: n_648  <= TRANSPORT \:643.OUT\ AFTER 5300 ps;
AND3_596: n_649 <=  n_650  AND n_651  AND n_652;
INV_597: n_650  <= TRANSPORT NOT \:637.OUT\ AFTER 4800 ps;
INV_598: n_651  <= TRANSPORT NOT x_in(0) AFTER 12300 ps;
DELAY_599: n_652  <= TRANSPORT \:643.OUT\ AFTER 5300 ps;
AND1_600: n_653 <=  gnd;
DELAY_601: \:1109.OUT\  <= TRANSPORT n_655 AFTER 700 ps;
XOR2_602: n_655 <=  n_656  XOR n_664;
OR2_603: n_656 <=  n_657  OR n_661;
AND3_604: n_657 <=  n_658  AND n_659  AND n_660;
INV_605: n_658  <= TRANSPORT NOT \:673.OUT\ AFTER 2500 ps;
DELAY_606: n_659  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_607: n_660  <= TRANSPORT \:637.OUT\ AFTER 4800 ps;
AND2_608: n_661 <=  n_662  AND n_663;
DELAY_609: n_662  <= TRANSPORT \:673.OUT\ AFTER 2500 ps;
DELAY_610: n_663  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|:97.OUT\ AFTER 2500 ps;
AND1_611: n_664 <=  gnd;
INV_612: \:667.OUT\  <= TRANSPORT NOT \:667.OUT~NOT\;
DELAY_613: \:667.OUT~NOT\  <= TRANSPORT n_667 AFTER 700 ps;
XOR2_614: n_667 <=  n_668  XOR n_684;
OR4_615: n_668 <=  n_669  OR n_673  OR n_677  OR n_681;
AND3_616: n_669 <=  n_670  AND n_671  AND n_672;
INV_617: n_670  <= TRANSPORT NOT y_in(2) AFTER 19800 ps;
INV_618: n_671  <= TRANSPORT NOT y_in(1) AFTER 11600 ps;
INV_619: n_672  <= TRANSPORT NOT y_in(0) AFTER 12400 ps;
AND3_620: n_673 <=  n_674  AND n_675  AND n_676;
DELAY_621: n_674  <= TRANSPORT y_in(1) AFTER 11600 ps;
DELAY_622: n_675  <= TRANSPORT y_in(4) AFTER 11400 ps;
DELAY_623: n_676  <= TRANSPORT y_in(2) AFTER 19800 ps;
AND3_624: n_677 <=  n_678  AND n_679  AND n_680;
DELAY_625: n_678  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_626: n_679  <= TRANSPORT y_in(4) AFTER 11400 ps;
DELAY_627: n_680  <= TRANSPORT y_in(2) AFTER 19800 ps;
AND2_628: n_681 <=  n_682  AND n_683;
INV_629: n_682  <= TRANSPORT NOT y_in(2) AFTER 19800 ps;
INV_630: n_683  <= TRANSPORT NOT y_in(4) AFTER 11400 ps;
AND1_631: n_684 <=  gnd;
DELAY_632: \:1361.OUT\  <= TRANSPORT n_685 AFTER 700 ps;
XOR2_633: n_685 <=  n_686  XOR n_697;
OR3_634: n_686 <=  n_687  OR n_690  OR n_694;
AND2_635: n_687 <=  n_688  AND n_689;
INV_636: n_688  <= TRANSPORT NOT x_in(0) AFTER 12 ns;
DELAY_637: n_689  <= TRANSPORT \:1109.OUT\ AFTER 2500 ps;
AND3_638: n_690 <=  n_691  AND n_692  AND n_693;
INV_639: n_691  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 2500 ps;
INV_640: n_692  <= TRANSPORT NOT \:1109.OUT\ AFTER 2500 ps;
DELAY_641: n_693  <= TRANSPORT x_in(0) AFTER 12 ns;
AND2_642: n_694 <=  n_695  AND n_696;
DELAY_643: n_695  <= TRANSPORT \:1109.OUT\ AFTER 2500 ps;
DELAY_644: n_696  <= TRANSPORT \:667.OUT~NOT\ AFTER 2500 ps;
AND1_645: n_697 <=  gnd;
DELAY_646: \|lpm_add_sub:600|addcore:adder|:63.OUT\  <= TRANSPORT n_699 AFTER 700 ps;
XOR2_647: n_699 <=  n_700  XOR n_705;
OR1_648: n_700 <=  n_701;
AND3_649: n_701 <=  n_702  AND n_703  AND n_704;
INV_650: n_702  <= TRANSPORT NOT y_in(2) AFTER 19800 ps;
INV_651: n_703  <= TRANSPORT NOT y_in(1) AFTER 11600 ps;
INV_652: n_704  <= TRANSPORT NOT y_in(0) AFTER 12100 ps;
AND1_653: n_705 <=  gnd;
DELAY_654: \:661.OUT\  <= TRANSPORT n_707 AFTER 700 ps;
XOR2_655: n_707 <=  n_708  XOR n_719;
OR3_656: n_708 <=  n_709  OR n_712  OR n_716;
AND2_657: n_709 <=  n_710  AND n_711;
DELAY_658: n_710  <= TRANSPORT \|lpm_add_sub:600|addcore:adder|:63.OUT\ AFTER 5300 ps;
DELAY_659: n_711  <= TRANSPORT y_in(3) AFTER 16900 ps;
AND3_660: n_712 <=  n_713  AND n_714  AND n_715;
INV_661: n_713  <= TRANSPORT NOT y_in(3) AFTER 16900 ps;
INV_662: n_714  <= TRANSPORT NOT \|lpm_add_sub:600|addcore:adder|:63.OUT\ AFTER 5300 ps;
DELAY_663: n_715  <= TRANSPORT y_in(4) AFTER 12200 ps;
AND2_664: n_716 <=  n_717  AND n_718;
INV_665: n_717  <= TRANSPORT NOT y_in(4) AFTER 12200 ps;
DELAY_666: n_718  <= TRANSPORT y_in(3) AFTER 16900 ps;
AND1_667: n_719 <=  gnd;
DELAY_668: \|lpm_add_sub:1218|addcore:adder|:60.OUT\  <= TRANSPORT n_721 AFTER 700 ps;
XOR2_669: n_721 <=  n_722  XOR n_726;
OR1_670: n_722 <=  n_723;
AND2_671: n_723 <=  n_724  AND n_725;
DELAY_672: n_724  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_673: n_725  <= TRANSPORT \:1109.OUT\ AFTER 4800 ps;
AND1_674: n_726 <=  gnd;
DELAY_675: \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\  <= TRANSPORT n_728 AFTER 700 ps;
XOR2_676: n_728 <=  n_729  XOR n_738;
OR2_677: n_729 <=  n_730  OR n_734;
AND3_678: n_730 <=  n_731  AND n_732  AND n_733;
DELAY_679: n_731  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_680: n_732  <= TRANSPORT \:643.OUT\ AFTER 5300 ps;
DELAY_681: n_733  <= TRANSPORT \:637.OUT\ AFTER 4800 ps;
AND3_682: n_734 <=  n_735  AND n_736  AND n_737;
DELAY_683: n_735  <= TRANSPORT y_in(0) AFTER 12400 ps;
DELAY_684: n_736  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_685: n_737  <= TRANSPORT \:643.OUT\ AFTER 5300 ps;
AND1_686: n_738 <=  gnd;
DELAY_687: \|lpm_add_sub:589|addcore:adder|:81.OUT\  <= TRANSPORT n_740 AFTER 700 ps;
XOR2_688: n_740 <=  n_741  XOR n_756;
OR4_689: n_741 <=  n_742  OR n_747  OR n_750  OR n_753;
AND4_690: n_742 <=  n_743  AND n_744  AND n_745  AND n_746;
INV_691: n_743  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
INV_692: n_744  <= TRANSPORT NOT x_in(1) AFTER 12100 ps;
INV_693: n_745  <= TRANSPORT NOT x_in(0) AFTER 12400 ps;
DELAY_694: n_746  <= TRANSPORT x_in(3) AFTER 17600 ps;
AND2_695: n_747 <=  n_748  AND n_749;
INV_696: n_748  <= TRANSPORT NOT x_in(3) AFTER 17600 ps;
DELAY_697: n_749  <= TRANSPORT x_in(1) AFTER 12100 ps;
AND2_698: n_750 <=  n_751  AND n_752;
INV_699: n_751  <= TRANSPORT NOT x_in(3) AFTER 17600 ps;
DELAY_700: n_752  <= TRANSPORT x_in(0) AFTER 12400 ps;
AND2_701: n_753 <=  n_754  AND n_755;
INV_702: n_754  <= TRANSPORT NOT x_in(3) AFTER 17600 ps;
DELAY_703: n_755  <= TRANSPORT x_in(2) AFTER 11800 ps;
AND1_704: n_756 <=  gnd;
DELAY_705: \:631.OUT\  <= TRANSPORT n_757 AFTER 700 ps;
XOR2_706: n_757 <=  n_758  XOR n_765;
OR2_707: n_758 <=  n_759  OR n_762;
AND2_708: n_759 <=  n_760  AND n_761;
DELAY_709: n_760  <= TRANSPORT y_in(4) AFTER 11800 ps;
DELAY_710: n_761  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:81.OUT\ AFTER 2500 ps;
AND2_711: n_762 <=  n_763  AND n_764;
INV_712: n_763  <= TRANSPORT NOT y_in(4) AFTER 11800 ps;
DELAY_713: n_764  <= TRANSPORT x_in(3) AFTER 17600 ps;
AND1_714: n_765 <=  gnd;
DELAY_715: \|lpm_add_sub:972|addcore:adder|:98.OUT\  <= TRANSPORT n_767 AFTER 700 ps;
XOR2_716: n_767 <=  n_768  XOR n_795;
OR6_717: n_768 <=  n_769  OR n_774  OR n_778  OR n_782  OR n_787  OR n_791;
AND4_718: n_769 <=  n_770  AND n_771  AND n_772  AND n_773;
DELAY_719: n_770  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_720: n_771  <= TRANSPORT \:637.OUT\ AFTER 5400 ps;
DELAY_721: n_772  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
DELAY_722: n_773  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND3_723: n_774 <=  n_775  AND n_776  AND n_777;
INV_724: n_775  <= TRANSPORT NOT \:631.OUT\ AFTER 5900 ps;
INV_725: n_776  <= TRANSPORT NOT \:637.OUT\ AFTER 5400 ps;
DELAY_726: n_777  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
AND3_727: n_778 <=  n_779  AND n_780  AND n_781;
INV_728: n_779  <= TRANSPORT NOT \:637.OUT\ AFTER 5400 ps;
INV_729: n_780  <= TRANSPORT NOT y_in(0) AFTER 13100 ps;
DELAY_730: n_781  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
AND4_731: n_782 <=  n_783  AND n_784  AND n_785  AND n_786;
INV_732: n_783  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
INV_733: n_784  <= TRANSPORT NOT \:637.OUT\ AFTER 5400 ps;
DELAY_734: n_785  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_735: n_786  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND3_736: n_787 <=  n_788  AND n_789  AND n_790;
INV_737: n_788  <= TRANSPORT NOT \:631.OUT\ AFTER 5900 ps;
INV_738: n_789  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
DELAY_739: n_790  <= TRANSPORT \:637.OUT\ AFTER 5400 ps;
AND3_740: n_791 <=  n_792  AND n_793  AND n_794;
INV_741: n_792  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 5200 ps;
INV_742: n_793  <= TRANSPORT NOT y_in(0) AFTER 13100 ps;
DELAY_743: n_794  <= TRANSPORT \:637.OUT\ AFTER 5400 ps;
AND1_744: n_795 <=  gnd;
DELAY_745: \:1103.OUT\  <= TRANSPORT n_797 AFTER 700 ps;
XOR2_746: n_797 <=  n_798  XOR n_806;
OR2_747: n_798 <=  n_799  OR n_802;
AND2_748: n_799 <=  n_800  AND n_801;
DELAY_749: n_800  <= TRANSPORT \:673.OUT\ AFTER 5500 ps;
DELAY_750: n_801  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|:98.OUT\ AFTER 2200 ps;
AND3_751: n_802 <=  n_803  AND n_804  AND n_805;
INV_752: n_803  <= TRANSPORT NOT \:673.OUT\ AFTER 5500 ps;
DELAY_753: n_804  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_754: n_805  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND1_755: n_806 <=  gnd;
DELAY_756: \:1355.OUT\  <= TRANSPORT n_808 AFTER 700 ps;
XOR2_757: n_808 <=  n_809  XOR n_831;
OR5_758: n_809 <=  n_810  OR n_815  OR n_820  OR n_824  OR n_828;
AND4_759: n_810 <=  n_811  AND n_812  AND n_813  AND n_814;
INV_760: n_811  <= TRANSPORT NOT \:1103.OUT\ AFTER 4800 ps;
INV_761: n_812  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 4900 ps;
INV_762: n_813  <= TRANSPORT NOT \:643.OUT\ AFTER 5200 ps;
DELAY_763: n_814  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|:60.OUT\ AFTER 2500 ps;
AND4_764: n_815 <=  n_816  AND n_817  AND n_818  AND n_819;
INV_765: n_816  <= TRANSPORT NOT \:1103.OUT\ AFTER 4800 ps;
INV_766: n_817  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|:60.OUT\ AFTER 2500 ps;
INV_767: n_818  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 4900 ps;
DELAY_768: n_819  <= TRANSPORT \:643.OUT\ AFTER 5200 ps;
AND3_769: n_820 <=  n_821  AND n_822  AND n_823;
DELAY_770: n_821  <= TRANSPORT \:643.OUT\ AFTER 5200 ps;
DELAY_771: n_822  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|:60.OUT\ AFTER 2500 ps;
DELAY_772: n_823  <= TRANSPORT \:1103.OUT\ AFTER 4800 ps;
AND3_773: n_824 <=  n_825  AND n_826  AND n_827;
INV_774: n_825  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|:60.OUT\ AFTER 2500 ps;
INV_775: n_826  <= TRANSPORT NOT \:643.OUT\ AFTER 5200 ps;
DELAY_776: n_827  <= TRANSPORT \:1103.OUT\ AFTER 4800 ps;
AND2_777: n_828 <=  n_829  AND n_830;
DELAY_778: n_829  <= TRANSPORT \:667.OUT~NOT\ AFTER 4900 ps;
DELAY_779: n_830  <= TRANSPORT \:1103.OUT\ AFTER 4800 ps;
AND1_780: n_831 <=  gnd;
DELAY_781: \:1607.OUT\  <= TRANSPORT n_832 AFTER 700 ps;
XOR2_782: n_832 <=  n_833  XOR n_844;
OR3_783: n_833 <=  n_834  OR n_837  OR n_840;
AND2_784: n_834 <=  n_835  AND n_836;
INV_785: n_835  <= TRANSPORT NOT \:661.OUT\ AFTER 5600 ps;
DELAY_786: n_836  <= TRANSPORT \:1355.OUT\ AFTER 2500 ps;
AND2_787: n_837 <=  n_838  AND n_839;
INV_788: n_838  <= TRANSPORT NOT x_in(0) AFTER 12300 ps;
DELAY_789: n_839  <= TRANSPORT \:1355.OUT\ AFTER 2500 ps;
AND3_790: n_840 <=  n_841  AND n_842  AND n_843;
INV_791: n_841  <= TRANSPORT NOT \:1355.OUT\ AFTER 2500 ps;
DELAY_792: n_842  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_793: n_843  <= TRANSPORT \:661.OUT\ AFTER 5600 ps;
AND1_794: n_844 <=  gnd;
DELAY_795: \|lpm_add_sub:589|addcore:adder|:63.OUT\  <= TRANSPORT n_846 AFTER 700 ps;
XOR2_796: n_846 <=  n_847  XOR n_852;
OR1_797: n_847 <=  n_848;
AND3_798: n_848 <=  n_849  AND n_850  AND n_851;
INV_799: n_849  <= TRANSPORT NOT x_in(2) AFTER 11800 ps;
INV_800: n_850  <= TRANSPORT NOT x_in(1) AFTER 12100 ps;
INV_801: n_851  <= TRANSPORT NOT x_in(0) AFTER 12400 ps;
AND1_802: n_852 <=  gnd;
DELAY_803: \|lpm_add_sub:589|addcore:adder|:82.OUT\  <= TRANSPORT n_854 AFTER 700 ps;
XOR2_804: n_854 <=  n_855  XOR n_866;
OR3_805: n_855 <=  n_856  OR n_860  OR n_863;
AND3_806: n_856 <=  n_857  AND n_858  AND n_859;
INV_807: n_857  <= TRANSPORT NOT x_in(3) AFTER 17600 ps;
DELAY_808: n_858  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:63.OUT\ AFTER 2200 ps;
DELAY_809: n_859  <= TRANSPORT x_in(4) AFTER 17500 ps;
AND2_810: n_860 <=  n_861  AND n_862;
INV_811: n_861  <= TRANSPORT NOT x_in(4) AFTER 17500 ps;
INV_812: n_862  <= TRANSPORT NOT \|lpm_add_sub:589|addcore:adder|:63.OUT\ AFTER 2200 ps;
AND2_813: n_863 <=  n_864  AND n_865;
INV_814: n_864  <= TRANSPORT NOT x_in(4) AFTER 17500 ps;
DELAY_815: n_865  <= TRANSPORT x_in(3) AFTER 17600 ps;
AND1_816: n_866 <=  gnd;
DELAY_817: \:625.OUT\  <= TRANSPORT n_867 AFTER 700 ps;
XOR2_818: n_867 <=  n_868  XOR n_875;
OR2_819: n_868 <=  n_869  OR n_872;
AND2_820: n_869 <=  n_870  AND n_871;
DELAY_821: n_870  <= TRANSPORT y_in(4) AFTER 11800 ps;
DELAY_822: n_871  <= TRANSPORT \|lpm_add_sub:589|addcore:adder|:82.OUT\ AFTER 2500 ps;
AND2_823: n_872 <=  n_873  AND n_874;
INV_824: n_873  <= TRANSPORT NOT y_in(4) AFTER 11800 ps;
DELAY_825: n_874  <= TRANSPORT x_in(4) AFTER 17500 ps;
AND1_826: n_875 <=  gnd;
DELAY_827: \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\  <= TRANSPORT n_876 AFTER 700 ps;
XOR2_828: n_876 <=  n_877  XOR n_889;
OR3_829: n_877 <=  n_878  OR n_882  OR n_885;
AND3_830: n_878 <=  n_879  AND n_880  AND n_881;
DELAY_831: n_879  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_832: n_880  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 4900 ps;
DELAY_833: n_881  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND2_834: n_882 <=  n_883  AND n_884;
DELAY_835: n_883  <= TRANSPORT \:637.OUT\ AFTER 5700 ps;
DELAY_836: n_884  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry1.OUT\ AFTER 4900 ps;
AND3_837: n_885 <=  n_886  AND n_887  AND n_888;
DELAY_838: n_886  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_839: n_887  <= TRANSPORT \:637.OUT\ AFTER 5700 ps;
DELAY_840: n_888  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND1_841: n_889 <=  gnd;
DELAY_842: \|lpm_add_sub:972|addcore:adder|:99.OUT\  <= TRANSPORT n_891 AFTER 700 ps;
XOR2_843: n_891 <=  n_892  XOR n_919;
OR6_844: n_892 <=  n_893  OR n_898  OR n_902  OR n_906  OR n_911  OR n_915;
AND4_845: n_893 <=  n_894  AND n_895  AND n_896  AND n_897;
DELAY_846: n_894  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_847: n_895  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
DELAY_848: n_896  <= TRANSPORT \:625.OUT\ AFTER 5900 ps;
DELAY_849: n_897  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
AND3_850: n_898 <=  n_899  AND n_900  AND n_901;
INV_851: n_899  <= TRANSPORT NOT \:625.OUT\ AFTER 5900 ps;
INV_852: n_900  <= TRANSPORT NOT \:631.OUT\ AFTER 5900 ps;
DELAY_853: n_901  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
AND3_854: n_902 <=  n_903  AND n_904  AND n_905;
INV_855: n_903  <= TRANSPORT NOT \:631.OUT\ AFTER 5900 ps;
INV_856: n_904  <= TRANSPORT NOT y_in(0) AFTER 13100 ps;
DELAY_857: n_905  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
AND4_858: n_906 <=  n_907  AND n_908  AND n_909  AND n_910;
INV_859: n_907  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
INV_860: n_908  <= TRANSPORT NOT \:631.OUT\ AFTER 5900 ps;
DELAY_861: n_909  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_862: n_910  <= TRANSPORT \:625.OUT\ AFTER 5900 ps;
AND3_863: n_911 <=  n_912  AND n_913  AND n_914;
INV_864: n_912  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
INV_865: n_913  <= TRANSPORT NOT \:625.OUT\ AFTER 5900 ps;
DELAY_866: n_914  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND3_867: n_915 <=  n_916  AND n_917  AND n_918;
INV_868: n_916  <= TRANSPORT NOT \|lpm_add_sub:972|addcore:adder|pcarry2.OUT\ AFTER 2200 ps;
INV_869: n_917  <= TRANSPORT NOT y_in(0) AFTER 13100 ps;
DELAY_870: n_918  <= TRANSPORT \:631.OUT\ AFTER 5900 ps;
AND1_871: n_919 <=  gnd;
DELAY_872: \:1097.OUT\  <= TRANSPORT n_921 AFTER 700 ps;
XOR2_873: n_921 <=  n_922  XOR n_930;
OR2_874: n_922 <=  n_923  OR n_927;
AND3_875: n_923 <=  n_924  AND n_925  AND n_926;
INV_876: n_924  <= TRANSPORT NOT \:673.OUT\ AFTER 5500 ps;
DELAY_877: n_925  <= TRANSPORT y_in(0) AFTER 13100 ps;
DELAY_878: n_926  <= TRANSPORT \:625.OUT\ AFTER 5900 ps;
AND2_879: n_927 <=  n_928  AND n_929;
DELAY_880: n_928  <= TRANSPORT \:673.OUT\ AFTER 5500 ps;
DELAY_881: n_929  <= TRANSPORT \|lpm_add_sub:972|addcore:adder|:99.OUT\ AFTER 2200 ps;
AND1_882: n_930 <=  gnd;
DELAY_883: \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\  <= TRANSPORT n_932 AFTER 700 ps;
XOR2_884: n_932 <=  n_933  XOR n_945;
OR3_885: n_933 <=  n_934  OR n_937  OR n_941;
AND2_886: n_934 <=  n_935  AND n_936;
DELAY_887: n_935  <= TRANSPORT \:643.OUT\ AFTER 5700 ps;
DELAY_888: n_936  <= TRANSPORT \:1103.OUT\ AFTER 2200 ps;
AND3_889: n_937 <=  n_938  AND n_939  AND n_940;
DELAY_890: n_938  <= TRANSPORT x_in(0) AFTER 12900 ps;
DELAY_891: n_939  <= TRANSPORT \:1109.OUT\ AFTER 5300 ps;
DELAY_892: n_940  <= TRANSPORT \:1103.OUT\ AFTER 2200 ps;
AND3_893: n_941 <=  n_942  AND n_943  AND n_944;
DELAY_894: n_942  <= TRANSPORT x_in(0) AFTER 12900 ps;
DELAY_895: n_943  <= TRANSPORT \:643.OUT\ AFTER 5700 ps;
DELAY_896: n_944  <= TRANSPORT \:1109.OUT\ AFTER 5300 ps;
AND1_897: n_945 <=  gnd;
DELAY_898: \:1349.OUT\  <= TRANSPORT n_947 AFTER 700 ps;
XOR2_899: n_947 <=  n_948  XOR n_970;
OR5_900: n_948 <=  n_949  OR n_953  OR n_958  OR n_962  OR n_967;
AND3_901: n_949 <=  n_950  AND n_951  AND n_952;
DELAY_902: n_950  <= TRANSPORT \:637.OUT\ AFTER 5400 ps;
DELAY_903: n_951  <= TRANSPORT \:1097.OUT\ AFTER 2500 ps;
DELAY_904: n_952  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND4_905: n_953 <=  n_954  AND n_955  AND n_956  AND n_957;
INV_906: n_954  <= TRANSPORT NOT \:1097.OUT\ AFTER 2500 ps;
INV_907: n_955  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 5600 ps;
INV_908: n_956  <= TRANSPORT NOT \:637.OUT\ AFTER 5400 ps;
DELAY_909: n_957  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND3_910: n_958 <=  n_959  AND n_960  AND n_961;
INV_911: n_959  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
INV_912: n_960  <= TRANSPORT NOT \:637.OUT\ AFTER 5400 ps;
DELAY_913: n_961  <= TRANSPORT \:1097.OUT\ AFTER 2500 ps;
AND4_914: n_962 <=  n_963  AND n_964  AND n_965  AND n_966;
INV_915: n_963  <= TRANSPORT NOT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
INV_916: n_964  <= TRANSPORT NOT \:1097.OUT\ AFTER 2500 ps;
INV_917: n_965  <= TRANSPORT NOT \:667.OUT~NOT\ AFTER 5600 ps;
DELAY_918: n_966  <= TRANSPORT \:637.OUT\ AFTER 5400 ps;
AND2_919: n_967 <=  n_968  AND n_969;
DELAY_920: n_968  <= TRANSPORT \:667.OUT~NOT\ AFTER 5600 ps;
DELAY_921: n_969  <= TRANSPORT \:1097.OUT\ AFTER 2500 ps;
AND1_922: n_970 <=  gnd;
DELAY_923: \|lpm_add_sub:1464|addcore:adder|:60.OUT\  <= TRANSPORT n_972 AFTER 700 ps;
XOR2_924: n_972 <=  n_973  XOR n_977;
OR1_925: n_973 <=  n_974;
AND2_926: n_974 <=  n_975  AND n_976;
DELAY_927: n_975  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_928: n_976  <= TRANSPORT \:1355.OUT\ AFTER 2500 ps;
AND1_929: n_977 <=  gnd;
DELAY_930: \:1601.OUT\  <= TRANSPORT n_978 AFTER 700 ps;
XOR2_931: n_978 <=  n_979  XOR n_1001;
OR5_932: n_979 <=  n_980  OR n_983  OR n_987  OR n_991  OR n_996;
AND2_933: n_980 <=  n_981  AND n_982;
INV_934: n_981  <= TRANSPORT NOT \:661.OUT\ AFTER 5600 ps;
DELAY_935: n_982  <= TRANSPORT \:1349.OUT\ AFTER 5300 ps;
AND3_936: n_983 <=  n_984  AND n_985  AND n_986;
DELAY_937: n_984  <= TRANSPORT \:643.OUT\ AFTER 4900 ps;
DELAY_938: n_985  <= TRANSPORT \:1349.OUT\ AFTER 5300 ps;
DELAY_939: n_986  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|:60.OUT\ AFTER 2500 ps;
AND3_940: n_987 <=  n_988  AND n_989  AND n_990;
INV_941: n_988  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|:60.OUT\ AFTER 2500 ps;
INV_942: n_989  <= TRANSPORT NOT \:643.OUT\ AFTER 4900 ps;
DELAY_943: n_990  <= TRANSPORT \:1349.OUT\ AFTER 5300 ps;
AND4_944: n_991 <=  n_992  AND n_993  AND n_994  AND n_995;
INV_945: n_992  <= TRANSPORT NOT \:1349.OUT\ AFTER 5300 ps;
INV_946: n_993  <= TRANSPORT NOT \:643.OUT\ AFTER 4900 ps;
DELAY_947: n_994  <= TRANSPORT \:661.OUT\ AFTER 5600 ps;
DELAY_948: n_995  <= TRANSPORT \|lpm_add_sub:1464|addcore:adder|:60.OUT\ AFTER 2500 ps;
AND4_949: n_996 <=  n_997  AND n_998  AND n_999  AND n_1000;
INV_950: n_997  <= TRANSPORT NOT \|lpm_add_sub:1464|addcore:adder|:60.OUT\ AFTER 2500 ps;
INV_951: n_998  <= TRANSPORT NOT \:1349.OUT\ AFTER 5300 ps;
DELAY_952: n_999  <= TRANSPORT \:643.OUT\ AFTER 4900 ps;
DELAY_953: n_1000  <= TRANSPORT \:661.OUT\ AFTER 5600 ps;
AND1_954: n_1001 <=  gnd;
DELAY_955: \:657.OUT\  <= TRANSPORT n_1002 AFTER 700 ps;
XOR2_956: n_1002 <=  n_1003  XOR n_1008;
OR1_957: n_1003 <=  n_1004;
AND3_958: n_1004 <=  n_1005  AND n_1006  AND n_1007;
INV_959: n_1005  <= TRANSPORT NOT y_in(3) AFTER 16900 ps;
DELAY_960: n_1006  <= TRANSPORT y_in(4) AFTER 12200 ps;
DELAY_961: n_1007  <= TRANSPORT \|lpm_add_sub:600|addcore:adder|:63.OUT\ AFTER 5300 ps;
AND1_962: n_1008 <=  gnd;
DELAY_963: \:1888.OUT\  <= TRANSPORT n_1009 AFTER 700 ps;
XOR2_964: n_1009 <=  n_1010  XOR n_1021;
OR3_965: n_1010 <=  n_1011  OR n_1014  OR n_1017;
AND2_966: n_1011 <=  n_1012  AND n_1013;
INV_967: n_1012  <= TRANSPORT NOT \:657.OUT\ AFTER 5600 ps;
DELAY_968: n_1013  <= TRANSPORT \:1601.OUT\ AFTER 2500 ps;
AND2_969: n_1014 <=  n_1015  AND n_1016;
INV_970: n_1015  <= TRANSPORT NOT x_in(0) AFTER 12300 ps;
DELAY_971: n_1016  <= TRANSPORT \:1601.OUT\ AFTER 2500 ps;
AND3_972: n_1017 <=  n_1018  AND n_1019  AND n_1020;
INV_973: n_1018  <= TRANSPORT NOT \:1601.OUT\ AFTER 2500 ps;
DELAY_974: n_1019  <= TRANSPORT x_in(0) AFTER 12300 ps;
DELAY_975: n_1020  <= TRANSPORT \:657.OUT\ AFTER 5600 ps;
AND1_976: n_1021 <=  gnd;
DELAY_977: \|lpm_add_sub:1716|addcore:adder|~97~1.OUT\  <= TRANSPORT n_1022 AFTER 700 ps;
XOR2_978: n_1022 <=  n_1023  XOR n_1034;
OR3_979: n_1023 <=  n_1024  OR n_1027  OR n_1031;
AND2_980: n_1024 <=  n_1025  AND n_1026;
INV_981: n_1025  <= TRANSPORT NOT x_in(0) AFTER 12300 ps;
DELAY_982: n_1026  <= TRANSPORT x_in(1) AFTER 11600 ps;
AND3_983: n_1027 <=  n_1028  AND n_1029  AND n_1030;
INV_984: n_1028  <= TRANSPORT NOT \:1601.OUT\ AFTER 2500 ps;
INV_985: n_1029  <= TRANSPORT NOT x_in(1) AFTER 11600 ps;
DELAY_986: n_1030  <= TRANSPORT x_in(0) AFTER 12300 ps;
AND2_987: n_1031 <=  n_1032  AND n_1033;
DELAY_988: n_1032  <= TRANSPORT x_in(1) AFTER 11600 ps;
DELAY_989: n_1033  <= TRANSPORT \:1601.OUT\ AFTER 2500 ps;
AND1_990: n_1034 <=  gnd;
DELAY_991: \|lpm_add_sub:1464|addcore:adder|pcarry1.OUT\  <= TRANSPORT n_1035 AFTER 700 ps;
XOR2_992: n_1035 <=  n_1036  XOR n_1048;
OR3_993: n_1036 <=  n_1037  OR n_1040  OR n_1044;
AND2_994: n_1037 <=  n_1038  AND n_1039;
DELAY_995: n_1038  <= TRANSPORT \:643.OUT\ AFTER 5500 ps;
DELAY_996: n_1039  <= TRANSPORT \:1349.OUT\ AFTER 4800 ps;
AND3_997: n_1040 <=  n_1041  AND n_1042  AND n_1043;
DELAY_998: n_1041  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_999: n_1042  <= TRANSPORT \:1355.OUT\ AFTER 4900 ps;
DELAY_1000: n_1043  <= TRANSPORT \:1349.OUT\ AFTER 4800 ps;
AND3_1001: n_1044 <=  n_1045  AND n_1046  AND n_1047;
DELAY_1002: n_1045  <= TRANSPORT x_in(0) AFTER 12700 ps;
DELAY_1003: n_1046  <= TRANSPORT \:643.OUT\ AFTER 5500 ps;
DELAY_1004: n_1047  <= TRANSPORT \:1355.OUT\ AFTER 4900 ps;
AND1_1005: n_1048 <=  gnd;
DELAY_1006: \|lpm_add_sub:1218|addcore:adder|pcarry2.OUT\  <= TRANSPORT n_1049 AFTER 700 ps;
XOR2_1007: n_1049 <=  n_1050  XOR n_1060;
OR3_1008: n_1050 <=  n_1051  OR n_1054  OR n_1057;
AND2_1009: n_1051 <=  n_1052  AND n_1053;
DELAY_1010: n_1052  <= TRANSPORT \:637.OUT\ AFTER 5700 ps;
DELAY_1011: n_1053  <= TRANSPORT \:1097.OUT\ AFTER 2200 ps;
AND2_1012: n_1054 <=  n_1055  AND n_1056;
DELAY_1013: n_1055  <= TRANSPORT \:1097.OUT\ AFTER 2200 ps;
DELAY_1014: n_1056  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND2_1015: n_1057 <=  n_1058  AND n_1059;
DELAY_1016: n_1058  <= TRANSPORT \:637.OUT\ AFTER 5700 ps;
DELAY_1017: n_1059  <= TRANSPORT \|lpm_add_sub:1218|addcore:adder|pcarry1.OUT\ AFTER 2500 ps;
AND1_1018: n_1060 <=  gnd;

END \EPF10K70RC240-4\;
