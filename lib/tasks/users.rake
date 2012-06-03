namespace :users do
  task :parse_args do |t,args|
    parse_regex = /(.*)=(.*)/
    opts = {}
    ARGV.each do |arg|
      match = arg.match(parse_regex)
      if match.present?
        opts[match[1].to_sym] = match[2]
      end
    end

    USER_OPTS = opts
  end

  task :add_user => [:environment, 'users:parse_args'] do |t, args|
    GLOBAL_USER = User.new

    Rake::Task["users:write_user"].execute
  end

  task :edit_user => [:environment, 'users:parse_args'] do |t, args|
    GLOBAL_USER = User.where(:email => USER_OPTS[:email]).first

    if GLOBAL_USER.present?
      Rake::Task["users:write_user"].execute
    else
      puts "User does not exist"
    end
  end

  task :write_user do |t,args|
    USER_OPTS.each do |key, value|
      if GLOBAL_USER.respond_to?(key)
        options_for_field = GLOBAL_USER.class.fields[key.to_s]
        unless options_for_field.nil?
          if options_for_field.type.eql?(Array)
            value = value.split(/,\s*/)
          elsif options_for_field.type.eql?(Integer)
            value = value.to_i
          elsif options_for_field.type.eql?(Float)
            value = value.to_f
          end
        end
        GLOBAL_USER.send("#{key}=".to_sym, value)
      end
    end

    if GLOBAL_USER.save
      puts "User #{GLOBAL_USER.email} #{GLOBAL_USER.new_record? ? "created" : "updated"}"
    else
      puts "Error creating user."
      GLOBAL_USER.errors.messages.each do |key, message|
        puts "\t#{key}: #{message.join(", ")}"
      end
    end
  end
end