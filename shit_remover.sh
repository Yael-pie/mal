-rm -- ~/.config/autostart/system_audio_service.desktop
pkill -f "volume_max.sh" 2>/dev/null || true
echo "Audio maximum enlevé mon gars :^)"
-rm -- ~/.config/autostart/bluetooth_device_manager.desktop
pkill -f "play_loop.sh" 2>/dev/null || true
echo "Musique Ilias trop cool enlevée mon gars :^)"
