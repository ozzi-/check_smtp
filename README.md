# check_smtp
This command will check if messages can be sent via smtp. It supports performance data.


## Setup
You need to have msmtp installed, on systems using apt, use:
```
apt install msmtp
```

Now create a file called /etc/msmtprc, following is a basic configuration.
More information can be found here https://www.systutorials.com/docs/linux/man/1-msmtp/#lbAH
```
# Set default values for all following accounts.
defaults
auth           off
tls            off
logfile        /var/log/msmtp.log

account        test
host           192.168.200.1
port           25
from           test@local.ch
user           test
password       password

account default: test
```

You can now test if msmtp is setup correctly as such:
```
echo -e "To: recipient@local.ch\nSubject: Test\n\nHello this is sending email using msmtp" | msmtp recipient@local.ch
```

## Usage
```
Usage: check_smtp [OPTIONS]
  [OPTIONS]:
  -c CRITICAL       Critical threshold for execution in milliseconds (default: 3500)
  -w WARNING        Warning threshold for execution in milliseconds (default: 2000)
  -M MESSAGE        Message to be sent (default: check_smtp message)
  -S SUBJECT        Subject to be send (default: check_smtp subject)
  -A ACCOUNT        Account to be used (default: default used in config file)
  -R RECIPIENT      Recipient E-Mail Address (use it multiple times for more recipients)
  Note: msmtp requires a config file under /etc/msmtprc
```

Example manually defining an account:
```
./check_smtp.sh -R recipient@local.ch -A test
```

Example setting custom message and a lower warning threshold:
```
./check_smtp.sh -R recipient@local.ch -M "Custom!" -w 1500
```

Example sending to multiple recipients:
```
./check_smtp.sh -R recipient@local.ch -R another@local.ch
```

## Command Template
```
object CheckCommand "check-smtp" {
  command = [ ConfigDir + "/scripts/check_smtp.sh" ]
  arguments += {
    "-c" = "2500"
    "-w" = "2000"
    "-M" = "Icinga Test"
    "-S" = "Icinga Test"
    "-A" = "test"
    "-R" = {
           value = "$recipient$"
           repeat_key = true
    }
  }
}
```
