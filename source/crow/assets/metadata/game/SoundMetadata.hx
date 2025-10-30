package crow.assets.metadata.game;

import crow.music.TempoStruct;
import crow.music.TimeSignatureStruct;

typedef SoundMetadata = 
{
    var looped:Bool;
    var volume:Float;

    var ?title:String;
    var ?artist:String;

    var ?tempo:Float;
    var ?timeSignature:TimeSignatureStruct;
    var ?offset:Float;

    var ?tempoChanges:Array<TempoStruct>;
    var ?timeSignatures:Array<TimeSignatureStruct>;
};