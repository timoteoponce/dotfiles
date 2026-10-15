# Menu entries that open Microsoft Edge in app mode.
# Signing in still happens once, inside Edge.
{ pkgs, ... }:
let
  edge = "${pkgs.microsoft-edge}/bin/microsoft-edge-stable";
  app =
    {
      name,
      desktopName,
      url,
      comment,
    }:
    pkgs.makeDesktopItem {
      inherit name desktopName comment;
      exec = "${edge} --app=${url}";
      icon = "microsoft-edge";
      categories = [
        "Network"
        "Office"
      ];
      startupNotify = true;
    };
in
{
  environment.systemPackages = [
    (app {
      name = "edge-teams";
      desktopName = "Teams";
      url = "https://teams.microsoft.com/v2/";
      comment = "Microsoft Teams";
    })
    (app {
      name = "edge-outlook";
      desktopName = "Outlook";
      url = "https://outlook.office.com/mail/";
      comment = "Outlook on the web";
    })
    (app {
      name = "edge-calendar";
      desktopName = "Calendar";
      url = "https://outlook.office.com/calendar/";
      comment = "Outlook Calendar";
    })
    (app {
      name = "edge-onedrive";
      desktopName = "OneDrive";
      url = "https://www.office.com/launch/onedrive";
      comment = "OneDrive";
    })
    (app {
      name = "edge-google-drive";
      desktopName = "Google Drive";
      url = "https://drive.google.com/";
      comment = "Google Drive";
    })
    (app {
      name = "edge-youtube";
      desktopName = "YouTube";
      url = "https://www.youtube.com/";
      comment = "YouTube";
    })
    (app {
      name = "edge-whatsapp";
      desktopName = "WhatsApp";
      url = "https://web.whatsapp.com/";
      comment = "WhatsApp";
    })
    (app {
      name = "edge-x";
      desktopName = "X";
      url = "https://x.com/";
      comment = "X";
    })
    (app {
      name = "edge-netflix";
      desktopName = "Netflix";
      url = "https://www.netflix.com/";
      comment = "Netflix";
    })
  ];
}
