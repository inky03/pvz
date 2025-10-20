local CreditWordType = {
	OFF = 0;
	AA = 1; EE = 2; AW = 3; OH = 4;
}
local CreditBrainType = {
	OFF = 0;
	NEXT_WORD = 1;
	FLY_OFF = 2; FLY_ON = 3;
	FAST_OFF = 4; FAST_ON = 5;
}

local ReanimatedMusicVideo = State:extend('ReanimatedMusicVideo') -- get it

ReanimatedMusicVideo.CreditBrainType = CreditBrainType
ReanimatedMusicVideo.CreditWordType = CreditWordType
ReanimatedMusicVideo.timing = {
	{frame = 128.5; word = CreditWordType.AW ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 133.0; word = CreditWordType.OH ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 136.5; word = CreditWordType.EE ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 140.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 141.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.NEXT_WORD };
	{frame = 143.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 145.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 149.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 153.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 155.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 159.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 163.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 171.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 172.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 173.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 175.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 177.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 181.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 185.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 187.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 191.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 193.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 199.0; word = CreditWordType.AA ; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 203.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 205.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FLY_ON	   };
	{frame = 207.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 209.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 213.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 217.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 219.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 223.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 227.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 231.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 234.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 235.0; word = CreditWordType.EE ; wordX = 150; brain = CreditBrainType.FAST_ON   };
	{frame = 237.0; word = CreditWordType.OH ; wordX = 220; brain = CreditBrainType.NEXT_WORD };
	{frame = 239.0; word = CreditWordType.AW ; wordX = 307; brain = CreditBrainType.NEXT_WORD };
	{frame = 241.0; word = CreditWordType.AW ; wordX = 390; brain = CreditBrainType.NEXT_WORD };
	{frame = 245.0; word = CreditWordType.EE ; wordX = 452; brain = CreditBrainType.NEXT_WORD };
	{frame = 249.0; word = CreditWordType.AW ; wordX = 512; brain = CreditBrainType.NEXT_WORD };
	{frame = 251.0; word = CreditWordType.AW ; wordX = 573; brain = CreditBrainType.NEXT_WORD };
	{frame = 255.0; word = CreditWordType.AW ; wordX = 630; brain = CreditBrainType.NEXT_WORD };
	{frame = 257.0; word = CreditWordType.AW ; wordX = 656; brain = CreditBrainType.NEXT_WORD };
	{frame = 261.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 262.0; word = CreditWordType.AA ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 266.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 266.5; word = CreditWordType.AW ; wordX = 	96; brain = CreditBrainType.FAST_ON   };
	{frame = 268.5; word = CreditWordType.OH ; wordX = 154; brain = CreditBrainType.NEXT_WORD };
	{frame = 270.5; word = CreditWordType.OH ; wordX = 244; brain = CreditBrainType.NEXT_WORD };
	{frame = 272.5; word = CreditWordType.AW ; wordX = 329; brain = CreditBrainType.NEXT_WORD };
	{frame = 276.5; word = CreditWordType.AW ; wordX = 419; brain = CreditBrainType.NEXT_WORD };
	{frame = 279.5; word = CreditWordType.AW ; wordX = 506; brain = CreditBrainType.NEXT_WORD };
	{frame = 281.5; word = CreditWordType.AW ; wordX = 597; brain = CreditBrainType.NEXT_WORD };
	{frame = 284.5; word = CreditWordType.AW ; wordX = 671; brain = CreditBrainType.NEXT_WORD };
	{frame = 286.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 287.0; word = CreditWordType.OH ; wordX = 	48; brain = CreditBrainType.FAST_ON   };
	{frame = 288.0; word = CreditWordType.AW ; wordX = 125; brain = CreditBrainType.NEXT_WORD };
	{frame = 290.0; word = CreditWordType.OH ; wordX = 193; brain = CreditBrainType.NEXT_WORD };
	{frame = 291.0; word = CreditWordType.EE ; wordX = 254; brain = CreditBrainType.NEXT_WORD };
	{frame = 294.5; word = CreditWordType.AW ; wordX = 318; brain = CreditBrainType.NEXT_WORD };
	{frame = 295.0; word = CreditWordType.AW ; wordX = 375; brain = CreditBrainType.NEXT_WORD };
	{frame = 296.0; word = CreditWordType.AW ; wordX = 438; brain = CreditBrainType.NEXT_WORD };
	{frame = 297.0; word = CreditWordType.AW ; wordX = 480; brain = CreditBrainType.NEXT_WORD };
	{frame = 299.0; word = CreditWordType.AW ; wordX = 556; brain = CreditBrainType.NEXT_WORD };
	{frame = 301.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 303.0; word = CreditWordType.AW ; wordX = 675; brain = CreditBrainType.NEXT_WORD };
	{frame = 305.0; word = CreditWordType.AW ; wordX = 744; brain = CreditBrainType.NEXT_WORD };
	{frame = 307.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 309.5; word = CreditWordType.OFF; wordX = 207; brain = CreditBrainType.FLY_ON	  };
	{frame = 310.5; word = CreditWordType.OFF; wordX = 287; brain = CreditBrainType.NEXT_WORD };
	{frame = 311.5; word = CreditWordType.OFF; wordX = 365; brain = CreditBrainType.NEXT_WORD };
	{frame = 313.5; word = CreditWordType.OFF; wordX = 435; brain = CreditBrainType.NEXT_WORD };
	{frame = 315.5; word = CreditWordType.OFF; wordX = 518; brain = CreditBrainType.NEXT_WORD };
	{frame = 317.5; word = CreditWordType.OFF; wordX = 603; brain = CreditBrainType.NEXT_WORD };
	{frame = 318.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 319.5; word = CreditWordType.OFF; wordX = 198; brain = CreditBrainType.FAST_ON   };
	{frame = 320.5; word = CreditWordType.OFF; wordX = 264; brain = CreditBrainType.NEXT_WORD };
	{frame = 322.5; word = CreditWordType.OFF; wordX = 335; brain = CreditBrainType.NEXT_WORD };
	{frame = 323.5; word = CreditWordType.OFF; wordX = 411; brain = CreditBrainType.NEXT_WORD };
	{frame = 324.5; word = CreditWordType.OFF; wordX = 474; brain = CreditBrainType.NEXT_WORD };
	{frame = 326.5; word = CreditWordType.OFF; wordX = 527; brain = CreditBrainType.NEXT_WORD };
	{frame = 328.5; word = CreditWordType.OFF; wordX = 595; brain = CreditBrainType.NEXT_WORD };
	{frame = 332.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 337.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 339.5; word = CreditWordType.AW ; wordX = 190; brain = CreditBrainType.FLY_ON	   };
	{frame = 340.5; word = CreditWordType.AW ; wordX = 260; brain = CreditBrainType.NEXT_WORD };
	{frame = 342.5; word = CreditWordType.AA ; wordX = 314; brain = CreditBrainType.NEXT_WORD };
	{frame = 344.5; word = CreditWordType.AW ; wordX = 364; brain = CreditBrainType.NEXT_WORD };
	{frame = 347.5; word = CreditWordType.AW ; wordX = 426; brain = CreditBrainType.NEXT_WORD };
	{frame = 349.5; word = CreditWordType.OH ; wordX = 474; brain = CreditBrainType.NEXT_WORD };
	{frame = 350.5; word = CreditWordType.AW ; wordX = 538; brain = CreditBrainType.NEXT_WORD };
	{frame = 352.5; word = CreditWordType.EE ; wordX = 606; brain = CreditBrainType.NEXT_WORD };
	{frame = 353.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 354.5; word = CreditWordType.EE ; wordX = 187; brain = CreditBrainType.FAST_ON   };
	{frame = 356.5; word = CreditWordType.AW ; wordX = 242; brain = CreditBrainType.NEXT_WORD };
	{frame = 358.5; word = CreditWordType.OH ; wordX = 280; brain = CreditBrainType.NEXT_WORD };
	{frame = 359.5; word = CreditWordType.AW ; wordX = 340; brain = CreditBrainType.NEXT_WORD };
	{frame = 360.5; word = CreditWordType.AW ; wordX = 394; brain = CreditBrainType.NEXT_WORD };
	{frame = 361.5; word = CreditWordType.EE ; wordX = 439; brain = CreditBrainType.NEXT_WORD };
	{frame = 363.5; word = CreditWordType.AW ; wordX = 500; brain = CreditBrainType.NEXT_WORD };
	{frame = 364.5; word = CreditWordType.AW ; wordX = 550; brain = CreditBrainType.NEXT_WORD };
	{frame = 366.5; word = CreditWordType.EE ; wordX = 606; brain = CreditBrainType.NEXT_WORD };
	{frame = 369.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 371.5; word = CreditWordType.OFF; wordX = 200; brain = CreditBrainType.FLY_ON	   };
	{frame = 372.5; word = CreditWordType.OH ; wordX = 258; brain = CreditBrainType.NEXT_WORD };
	{frame = 374.5; word = CreditWordType.OFF; wordX = 332; brain = CreditBrainType.NEXT_WORD };
	{frame = 376.5; word = CreditWordType.OFF; wordX = 416; brain = CreditBrainType.NEXT_WORD };
	{frame = 378.5; word = CreditWordType.OFF; wordX = 494; brain = CreditBrainType.NEXT_WORD };
	{frame = 380.5; word = CreditWordType.OFF; wordX = 576; brain = CreditBrainType.NEXT_WORD };
	{frame = 381.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 382.5; word = CreditWordType.OFF; wordX = 255; brain = CreditBrainType.FAST_ON   };
	{frame = 384.5; word = CreditWordType.OFF; wordX = 322; brain = CreditBrainType.NEXT_WORD };
	{frame = 386.5; word = CreditWordType.OFF; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 388.5; word = CreditWordType.OFF; wordX = 474; brain = CreditBrainType.NEXT_WORD };
	{frame = 390.5; word = CreditWordType.OFF; wordX = 533; brain = CreditBrainType.NEXT_WORD };
	{frame = 394.5; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 522.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 523.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 525.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 527.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 531.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 535.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 537.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 541.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 545.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 549.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 554.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 555.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 557.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 559.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 563.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 567.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 569.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 573.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 575.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 581.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 582.0; word = CreditWordType.AA ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 586.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 587.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 589.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 591.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 595.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 599.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 601.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 605.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 609.0; word = CreditWordType.AW ; wordX = 619; brain = CreditBrainType.NEXT_WORD };
	{frame = 613.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 616.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 617.0; word = CreditWordType.EE ; wordX = 150; brain = CreditBrainType.FAST_ON   };
	{frame = 619.0; word = CreditWordType.OH ; wordX = 220; brain = CreditBrainType.NEXT_WORD };
	{frame = 621.0; word = CreditWordType.AW ; wordX = 307; brain = CreditBrainType.NEXT_WORD };
	{frame = 623.0; word = CreditWordType.AW ; wordX = 390; brain = CreditBrainType.NEXT_WORD };
	{frame = 627.0; word = CreditWordType.EE ; wordX = 452; brain = CreditBrainType.NEXT_WORD };
	{frame = 631.0; word = CreditWordType.AW ; wordX = 512; brain = CreditBrainType.NEXT_WORD };
	{frame = 633.0; word = CreditWordType.AW ; wordX = 573; brain = CreditBrainType.NEXT_WORD };
	{frame = 637.0; word = CreditWordType.AW ; wordX = 630; brain = CreditBrainType.NEXT_WORD };
	{frame = 639.0; word = CreditWordType.AW ; wordX = 656; brain = CreditBrainType.NEXT_WORD };
	{frame = 643.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 644.0; word = CreditWordType.AA ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 648.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 649.0; word = CreditWordType.AA ; wordX = 196; brain = CreditBrainType.FAST_ON   };
	{frame = 651.0; word = CreditWordType.EE ; wordX = 247; brain = CreditBrainType.NEXT_WORD };
	{frame = 653.0; word = CreditWordType.AW ; wordX = 299; brain = CreditBrainType.NEXT_WORD };
	{frame = 655.0; word = CreditWordType.AW ; wordX = 371; brain = CreditBrainType.NEXT_WORD };
	{frame = 658.0; word = CreditWordType.OH ; wordX = 443; brain = CreditBrainType.NEXT_WORD };
	{frame = 659.0; word = CreditWordType.EE ; wordX = 475; brain = CreditBrainType.NEXT_WORD };
	{frame = 661.0; word = CreditWordType.AW ; wordX = 512; brain = CreditBrainType.NEXT_WORD };
	{frame = 662.0; word = CreditWordType.AA ; wordX = 544; brain = CreditBrainType.NEXT_WORD };
	{frame = 664.0; word = CreditWordType.OH ; wordX = 573; brain = CreditBrainType.NEXT_WORD };
	{frame = 667.0; word = CreditWordType.AA ; wordX = 610; brain = CreditBrainType.NEXT_WORD };
	{frame = 669.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 670.0; word = CreditWordType.OFF; wordX = 	48; brain = CreditBrainType.FAST_ON   };
	{frame = 671.0; word = CreditWordType.OFF; wordX = 110; brain = CreditBrainType.NEXT_WORD };
	{frame = 673.0; word = CreditWordType.OFF; wordX = 185; brain = CreditBrainType.NEXT_WORD };
	{frame = 674.0; word = CreditWordType.OFF; wordX = 262; brain = CreditBrainType.NEXT_WORD };
	{frame = 676.0; word = CreditWordType.OFF; wordX = 317; brain = CreditBrainType.NEXT_WORD };
	{frame = 677.0; word = CreditWordType.OFF; wordX = 357; brain = CreditBrainType.NEXT_WORD };
	{frame = 678.0; word = CreditWordType.OFF; wordX = 417; brain = CreditBrainType.NEXT_WORD };
	{frame = 679.0; word = CreditWordType.OFF; wordX = 491; brain = CreditBrainType.NEXT_WORD };
	{frame = 682.0; word = CreditWordType.OFF; wordX = 558; brain = CreditBrainType.NEXT_WORD };
	{frame = 685.0; word = CreditWordType.OFF; wordX = 628; brain = CreditBrainType.NEXT_WORD };
	{frame = 687.0; word = CreditWordType.OFF; wordX = 720; brain = CreditBrainType.NEXT_WORD };
	{frame = 689.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 690.0; word = CreditWordType.OFF; wordX = 172; brain = CreditBrainType.FAST_ON   };
	{frame = 692.0; word = CreditWordType.OFF; wordX = 263; brain = CreditBrainType.NEXT_WORD };
	{frame = 694.0; word = CreditWordType.OFF; wordX = 346; brain = CreditBrainType.NEXT_WORD };
	{frame = 696.0; word = CreditWordType.OFF; wordX = 423; brain = CreditBrainType.NEXT_WORD };
	{frame = 698.0; word = CreditWordType.OFF; wordX = 480; brain = CreditBrainType.NEXT_WORD };
	{frame = 700.0; word = CreditWordType.OFF; wordX = 536; brain = CreditBrainType.NEXT_WORD };
	{frame = 702.0; word = CreditWordType.OFF; wordX = 583; brain = CreditBrainType.NEXT_WORD };
	{frame = 705.0; word = CreditWordType.OFF; wordX = 633; brain = CreditBrainType.NEXT_WORD };
	{frame = 708.0; word = CreditWordType.OFF; wordX = 668; brain = CreditBrainType.NEXT_WORD };
	{frame = 712.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 719.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 720.0; word = CreditWordType.OFF; wordX = 182; brain = CreditBrainType.FAST_ON   };
	{frame = 722.0; word = CreditWordType.OFF; wordX = 267; brain = CreditBrainType.NEXT_WORD };
	{frame = 724.0; word = CreditWordType.OFF; wordX = 331; brain = CreditBrainType.NEXT_WORD };
	{frame = 726.0; word = CreditWordType.OFF; wordX = 371; brain = CreditBrainType.NEXT_WORD };
	{frame = 729.0; word = CreditWordType.OFF; wordX = 434; brain = CreditBrainType.NEXT_WORD };
	{frame = 731.0; word = CreditWordType.OFF; wordX = 486; brain = CreditBrainType.NEXT_WORD };
	{frame = 732.0; word = CreditWordType.OFF; wordX = 562; brain = CreditBrainType.NEXT_WORD };
	{frame = 734.0; word = CreditWordType.OFF; wordX = 617; brain = CreditBrainType.NEXT_WORD };
	{frame = 735.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 736.0; word = CreditWordType.AW ; wordX = 148; brain = CreditBrainType.FAST_ON   };
	{frame = 738.0; word = CreditWordType.AW ; wordX = 211; brain = CreditBrainType.NEXT_WORD };
	{frame = 740.0; word = CreditWordType.EE ; wordX = 298; brain = CreditBrainType.NEXT_WORD };
	{frame = 742.0; word = CreditWordType.OH ; wordX = 367; brain = CreditBrainType.NEXT_WORD };
	{frame = 744.0; word = CreditWordType.AW ; wordX = 440; brain = CreditBrainType.NEXT_WORD };
	{frame = 746.0; word = CreditWordType.OH ; wordX = 506; brain = CreditBrainType.NEXT_WORD };
	{frame = 747.0; word = CreditWordType.AW ; wordX = 533; brain = CreditBrainType.NEXT_WORD };
	{frame = 748.0; word = CreditWordType.AW ; wordX = 601; brain = CreditBrainType.NEXT_WORD };
	{frame = 749.0; word = CreditWordType.AW ; wordX = 645; brain = CreditBrainType.NEXT_WORD };
	{frame = 750.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FAST_OFF  };
	{frame = 753.0; word = CreditWordType.OFF; wordX = 123; brain = CreditBrainType.FLY_ON	   };
	{frame = 755.0; word = CreditWordType.OFF; wordX = 195; brain = CreditBrainType.NEXT_WORD };
	{frame = 757.0; word = CreditWordType.OFF; wordX = 255; brain = CreditBrainType.NEXT_WORD };
	{frame = 759.0; word = CreditWordType.OFF; wordX = 312; brain = CreditBrainType.NEXT_WORD };
	{frame = 761.0; word = CreditWordType.OFF; wordX = 378; brain = CreditBrainType.NEXT_WORD };
	{frame = 763.0; word = CreditWordType.OFF; wordX = 443; brain = CreditBrainType.NEXT_WORD };
	{frame = 765.0; word = CreditWordType.OFF; wordX = 516; brain = CreditBrainType.NEXT_WORD };
	{frame = 767.0; word = CreditWordType.OFF; wordX = 563; brain = CreditBrainType.NEXT_WORD };
	{frame = 770.0; word = CreditWordType.OFF; wordX = 588; brain = CreditBrainType.NEXT_WORD };
	{frame = 773.0; word = CreditWordType.OFF; wordX = 657; brain = CreditBrainType.NEXT_WORD };
	{frame = 777.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 907.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 908.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 910.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 912.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 916.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 920.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 922.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 926.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 930.0; word = CreditWordType.AW ; wordX = 616; brain = CreditBrainType.NEXT_WORD };
	{frame = 934.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 939.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 940.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 942.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 944.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 948.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 952.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 954.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 958.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 960.0; word = CreditWordType.AW ; wordX = 616; brain = CreditBrainType.NEXT_WORD };
	{frame = 966.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 967.0; word = CreditWordType.AA ; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 971.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.OFF	   };
	{frame = 972.0; word = CreditWordType.AW ; wordX = 214; brain = CreditBrainType.FAST_ON   };
	{frame = 974.0; word = CreditWordType.AW ; wordX = 297; brain = CreditBrainType.NEXT_WORD };
	{frame = 976.0; word = CreditWordType.AW ; wordX = 348; brain = CreditBrainType.NEXT_WORD };
	{frame = 980.0; word = CreditWordType.EE ; wordX = 400; brain = CreditBrainType.NEXT_WORD };
	{frame = 984.0; word = CreditWordType.AW ; wordX = 455; brain = CreditBrainType.NEXT_WORD };
	{frame = 986.0; word = CreditWordType.OH ; wordX = 523; brain = CreditBrainType.NEXT_WORD };
	{frame = 990.0; word = CreditWordType.AW ; wordX = 593; brain = CreditBrainType.NEXT_WORD };
	{frame = 994.0; word = CreditWordType.AW ; wordX = 616; brain = CreditBrainType.NEXT_WORD };
	{frame = 998.0; word = CreditWordType.OFF; wordX = 	 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 1001.0;  word = CreditWordType.OFF; wordX = 0; brain = CreditBrainType.OFF	   };
	{frame = 1002.0;  word = CreditWordType.EE ; wordX = 150; brain = CreditBrainType.FAST_ON   };
	{frame = 1004.0;  word = CreditWordType.OH ; wordX = 220; brain = CreditBrainType.NEXT_WORD };
	{frame = 1006.0;  word = CreditWordType.AW ; wordX = 307; brain = CreditBrainType.NEXT_WORD };
	{frame = 1008.0;  word = CreditWordType.AW ; wordX = 390; brain = CreditBrainType.NEXT_WORD };
	{frame = 1012.0;  word = CreditWordType.EE ; wordX = 452; brain = CreditBrainType.NEXT_WORD };
	{frame = 1016.0;  word = CreditWordType.AW ; wordX = 512; brain = CreditBrainType.NEXT_WORD };
	{frame = 1018.0;  word = CreditWordType.AW ; wordX = 573; brain = CreditBrainType.NEXT_WORD };
	{frame = 1022.0;  word = CreditWordType.AW ; wordX = 630; brain = CreditBrainType.NEXT_WORD };
	{frame = 1024.0;  word = CreditWordType.AW ; wordX = 656; brain = CreditBrainType.NEXT_WORD };
	{frame = 1028.0;  word = CreditWordType.OFF; wordX = 0; brain = CreditBrainType.FLY_OFF   };
	{frame = 1029.0;  word = CreditWordType.AA ; wordX = 0; brain = CreditBrainType.OFF	   };
	{frame = 1033.0;  word = CreditWordType.OFF; wordX = 0; brain = CreditBrainType.OFF	   };
}

function ReanimatedMusicVideo:init()
	State.init(self)
	
	self.creditsFrame = 0
	self.creditsPhase = 1
	self.song = Sound.play('ZombiesOnYourLawn', 0, 1, 'stream', false)
	self.songTime = 0
	self.bpm = 105
	self.beat = 0
	
	self.previousTiming = nil
	self.afterTiming = nil
	
	-- animation
	
	self.credits = self:addElement(Reanimation:new('Credits_Main'))
	self.sunflowerFace = 'Sunflower_head'
	
	--[[self.sunflowerFace = 'Sunflower_head'
	self.sunFlower = Reanimation:new('SunFlower')
	self.sunFlower.animation:add('idle', 'idle')
	self.sunFlower.animation:play('idle', true)
	self.stage = Reanimation:new('Credits_stage')
	self.zombieArmy1 = Reanimation:new('Credits_ZombieArmy1')
	self.zombieArmy2 = Reanimation:new('Credits_ZombieArmy2')
	self.zombie1 = Reanimation:new('Zombie_credits_dance')
	self.zombie2 = Reanimation:new('Zombie_credits_dance')
	
	self.dancers = {self.sunFlower, self.sunFlower2}
	
	self.credits:attach('attacher__Stage', self.stage)
	self.credits:attach('attacher__Stage2', self.stage)
	self.credits:attach('attacher__SunFlower', self.sunFlower)
	self.credits:attach('attacher__SunFlower2', self.sunFlower)
	self.credits:attach('attacher__ZombieArmy', self.zombieArmy1)
	self.credits:attach('attacher__ZombieArmy2', self.zombieArmy2)
	self.credits:attach('attacher__Zombie1', self.zombie1)
	self.credits:attach('attacher__Zombie2', self.zombie2)
	for _, army in ipairs{self.zombieArmy1, self.zombieArmy2} do
		for _, layer in ipairs(army.reanim:getLayers()) do
			local anim = layer.frames[1].text
			anim = anim:sub(#('attacher__Zombie_credits_dance__anim_') + 1, anim:find('%[') - 1)
			
			local zombie = Reanimation:new('Zombie_credits_dance')
			zombie.animation:add('dance', anim)
			zombie.animation:play('dance', true)
			
			army:attach(layer.name, zombie)
			table.insert(self.dancers, zombie)
		end
	end
	for _, zombie in ipairs{self.zombie1, self.zombie2} do
		zombie.animation:add('dance2', 'dance2')
		zombie.animation:add('dance4', 'dance4')
		zombie.animation:play('dance2', true)
	end]]
	
	self.song:play()
end

function ReanimatedMusicVideo:update(dt)
	State.update(self, dt)
	
	self:updateMovie()
	
	-- for _, dancer in ipairs(self.dancers) do
		-- dancer.animation:setFrame(self.beat % 2 / 2 * (dancer.animation.length - 1))
	-- end
end

function ReanimatedMusicVideo:updateTiming()
	self.songTime = self.song:tell()
	self.beat = (self.songTime / (60 / self.bpm))
	self.creditsFrame = self.credits.animation.frameFloat
	
	if self.creditsPhase == 1 then
		self.creditsFrame = (self.creditsFrame + 2)
	elseif self.creditsPhase == 2 then
		self.creditsFrame = (self.creditsFrame + 400)
	elseif self.creditsPhase == 3 then
		self.creditsFrame = (self.creditsFrame + 785)
	else
		self.creditsFrame = 0
	end
	
	if self.creditsFrame < self.timing[1].frame then
		self.previousTiming = nil
		self.afterTiming = self.timing[1]
	else
		for i, timing in ipairs(self.timing) do
			self.previousTiming = timing
			self.afterTiming = self.timing[i + 1]
			
			if not self.afterTiming or self.afterTiming.frame >= self.creditsFrame then
				break
			end
		end
	end
	
	self.timingFraction = ((self.previousTiming and self.afterTiming) and (math.remap(self.creditsFrame, self.previousTiming.frame, self.afterTiming.frame, 0, 1)) or 0)
end

function ReanimatedMusicVideo:updateMovie()
	self.credits.animation:setFrame(math.max(self.credits.animation.frameFloat, self.songTime * self.credits.reanim.fps))
	
	self:updateTiming()
	
	local frameFactor = (1 / self.credits.animation.length)
	if self.creditsPhase == 1 then
		if self.credits:shouldTriggerTimedEvent(frameFactor * 128) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 130) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 132) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 134) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 136) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 138) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 140) or
			self.credits:shouldTriggerTimedEvent(frameFactor * 142) then
			self:addElement(Particle:new('Credits_Strobe'))
		end if self.credits:shouldTriggerTimedEvent(frameFactor * 136.5) then
			self:addElement(Particle:new('Credits_RaysWipe', gameWidth * .5, gameHeight * .5))
		end if self.credits:shouldTriggerTimedEvent(frameFactor * 331) then
			self.scream = Sound.play('scream')
		end if self.credits:shouldTriggerTimedEvent(frameFactor * 337) and self.scream then
			self.scream:stop()
			self.scream = nil
		end
	end
	
	self.sunflowerFace = 'Sunflower_head'
	
	if self.previousTiming and self.afterTiming then
		local framesForWord = (self.afterTiming.frame - self.previousTiming.frame)
		local framesTillEnd = ((1 - self.timingFraction) * framesForWord)
		
		if self.previousTiming.word == CreditWordType.OFF then
			-- nothing
		elseif (framesForWord * self.timingFraction) < .2 or framesTillEnd < .4 then
			self.sunflowerFace = 'Sunflower_head_sing1'
		else
			self.sunflowerFace = ('Sunflower_head_sing' .. (self.previousTiming.word + 1))
		end
	end
	
	if prevFace ~= self.sunflowerFace then
		local sunFlower = self.credits:findAttachment('Sunflower')
		if sunFlower then sunFlower:replaceImage('Sunflower_head', Reanim.getResource(self.sunflowerFace)) end
	end
end

return ReanimatedMusicVideo