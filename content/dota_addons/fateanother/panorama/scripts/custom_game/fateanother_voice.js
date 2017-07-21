function PlayClientVoiceSound( event_data )
{
	Game.EmitSound( event_data.SoundEvent );
}

GameEvents.Subscribe( "PlayVoiceSound", PlayClientVoiceSound );