A proof of concept for a simple script to include text files within another text file.

The long-term aim is to create a very simple static site generator.
Within this static site generator everything will be a text file.
The idea is that you'd have a file for a HTML Partial e.g site navigation, a configuration value e.g. a contact email address, a message displayed on the site, and everything else.

The static site generator is essentially a very basic templating language.
It will allow you to include other files and should also allow you to reference files that you do not want to inline e.g images.
These files should be published to an assets directory for the site.

The syntax for a command is two opening curly braces, followed by the command name, followed by a list of arguments, followed by two closing curly braces.

```
{{ include body.html }}
```

## Example

```
php run.php -i example/site.html -o example/index.html
```

```
<!DOCTYPE html>
<html lang="en_GB">
<head>
    <title>Page title</title>
</head>

<body>Page Body!</body>

</html>
```


## TODO
- Add a command for referencing files that shouldn't be embedded.
- Prevent circular and infinite references.
- Write it in something other than PHP.
