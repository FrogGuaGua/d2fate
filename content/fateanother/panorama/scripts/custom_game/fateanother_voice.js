var bEnabledUnitVoice = true;

function PlayClientVoiceSound( event_data )
{
    if (bEnabledUnitVoice) {
        Game.EmitSound( event_data.SoundEvent );
    }
}

function EnableUnitVoice()
{
    bEnabledUnitVoice = true;
}

function DisableUnitVoice()
{
    bEnabledUnitVoice = false;
}


GameEvents.Subscribe( "PlayVoiceSound", PlayClientVoiceSound );
GameEvents.Subscribe( "fate_enable_voice", EnableUnitVoice );
GameEvents.Subscribe( "fate_disable_voice", DisableUnitVoice );