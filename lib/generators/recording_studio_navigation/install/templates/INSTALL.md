RecordingStudioNavigation install complete.

Next steps:

1. Review config/initializers/recording_studio_navigation.rb.
2. Connect the generated item href lambdas to your host app routes.
3. Pass current actor and current root recording into `RecordingStudioNavigation.context`.
4. Use `bin/rails generate recording_studio_navigation:migrations` only if you want the reminder that the gem has no tables of its own.
5. Run `bin/rails tailwindcss:build` if you use Tailwind CSS.
6. Keep auth, layout, and current actor integration in your host app and let visibility blocks read Recording Studio access data.
