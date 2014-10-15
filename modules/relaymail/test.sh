cat <<- EOF > /tmp/mail.test
To: $RELAYMAIL_TEST_EMAIL
Subject: Put a subject here
From: test

Of cause, here's the place to put the body
EOF

sendmail -vt < /tmp/mail.test
rm /tmp/mail.test

cat <<- EOM > /tmp/mail.test
To: root
Subject: Put a subject here (root msg)
From: test

Of cause, here's the place to put the body
EOM

sendmail -vt < /tmp/mail.test
rm /tmp/mail.test
