var output = {};

// Top Panel
var p = new Panel;
p.location = "top";
p.height = 32;

p.addWidget("org.kde.plasma.kickerdash");
p.addWidget("org.kde.plasma.pager");
p.addWidget("org.kde.plasma.panelspacer");

var clock = p.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showSeconds", "Always");
clock.writeConfig("dateDisplayFormat", "BesideTime");
clock.writeConfig("customDateFormat", "ddd d MMM");
clock.writeConfig("dateFormat", "custom");

p.addWidget("org.kde.plasma.panelspacer");
p.addWidget("org.kde.plasma.systemtray");

var logout = p.addWidget("org.kde.plasma.lock_logout");
logout.currentConfigGroup = ["General"]
logout.writeConfig("show_lockScreen", "false")

output.top_panel_id = p.id

// Bottom dock
var p = new Panel;
p.location = "bottom";
p.height = 48;

var tasks = p.addWidget("org.kde.plasma.icontasks")
tasks.currentConfigGroup = ["General"]
tasks.writeConfig("launchers", "preferred://browser,applications:kitty.desktop,preferred://filemanager,applications:systemsettings.desktop")

output.bottom_panel_id = p.id;
output.tasks_applet_id = tasks.id

output.all= panels().map(function (p) {
  return {
    id: p.id,
    location: p.location,
    screen: p.screen,
    height: p.height,
    widgets: p.widgetIds.map(function (wid) {
      var w = p.widgetById(wid);
      return { id: w.id, type: w.type };
    })
  };
});

print(JSON.stringify(output));
