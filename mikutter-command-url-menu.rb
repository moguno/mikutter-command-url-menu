#encoding: utf-8

Plugin.create(:"mikutter-command-url-menu") {
  command(:url_menu,
          :name => _("URLメニューを出す"),
          :condition => lambda { |opt| 
            Plugin::Command[:HasMessage] &&
            opt.messages.first[:entities] &&
            ((Array(opt.messages.first[:entities][:urls]).count != 0) ||
            (Array(opt.messages.first[:entities][:media]).count != 0))
          },
          :visible => false,
          :role => :timeline) { |opt|

    begin
      opt.messages.each { |message|
        menu = nil

        [
          { :key => :urls, :header => _("Web") },
          { :key => :media, :header => _("画像") },
        ].each { |params|
          Array(message[:entities][params[:key]]).each { |url|
            menu ||= Gtk::Menu.new

            item = Gtk::MenuItem.new("【#{params[:header]}】#{url[:expanded_url]}")

            item.ssc(:button_press_event) { |w, e|
              Gtk::openurl(url[:expanded_url])
              menu.destroy
            }

            menu.append(item)
          }
        }

        if menu
          menu.show_all
          menu.popup(nil, nil, 3, 0)
        end
      }
    rescue => e
      puts e
      puts e.backtrace
    end
  }
}
