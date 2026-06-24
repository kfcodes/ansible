# Ansible Role: kiosk_mode

This role configures a simple Ubuntu kiosk session.

It can:

- Configure TTY autologin
- Start X automatically on the kiosk TTY
- Launch Matchbox window manager
- Launch Onboard on-screen keyboard
- Launch Chromium in kiosk mode
- Optionally disable the managed kiosk startup again

## Responsibilities

This role owns kiosk-specific desktop/session behavior only.

It should not manage:

- User creation
- SSH access
- Docker
- Application deployment
- General base system configuration

Create the kiosk user with `user_account` before applying this role.

## Main variables

```yaml
kiosk_mode_enabled: true
kiosk_user: ubuntu
kiosk_autologin_tty: tty1
kiosk_url: "https://example.com" 
