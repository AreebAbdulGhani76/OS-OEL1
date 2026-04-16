
#!/bin/bash

mkdir -p /home/lab_users
mkdir -p /archives

while true; do
    echo "--- User Workspace Manager ---"
    echo "1. Create new user workspace"
    echo "2. Set disk quota for workspace"
    echo "3. Search for file by name/extension in all workspaces"
    echo "4. Archive inactive workspaces"
    echo "5. Exit"
    read -p "Select an option: " choice

    case $choice in
        1)
            read -p "Enter username: " username
            user_dir="/home/lab_users/$username"
            
            # Create directories 
            mkdir -p "$user_dir/docs" "$user_dir/code" "$user_dir/shared"
            
            # Set permissions: Only user + admin (root) can access 
            chmod 700 "$user_dir"
            echo "Workspace created for $username at $user_dir"
            ;;

        2)
            read -p "Enter username to check: " username
            user_dir="/home/lab_users/$username"

            if [ -d "$user_dir" ]; then
                # Use du to check size in MB 
                size=$(du -sm "$user_dir" | cut -f1)
                echo "Current workspace size: ${size}MB"

                # Simulate quota warning if > 100MB 
                if [ "$size" -gt 100 ]; then
                    echo "WARNING: Disk quota exceeded! Usage is above 100MB."
                else
                    echo "Usage is within limits."
                fi
            else
                echo "User workspace not found."
            fi
            ;;

        3)
            read -p "Enter filename or extension (e.g., .txt): " search_term
            echo "Searching all workspaces..."
            
            find /home/lab_users -name "*$search_term*" -printf "Path: %p | Size: %s bytes | Modified: %TY-%Tm-%Td %TH:%TM\n"
            ;;

        4)
            echo "Finding workspaces inactive for over 60 days..."
            # Find directories not modified in 60 days 
            for dir in /home/lab_users/*; do
                if [ -d "$dir" ]; then
                    mod_time=$(stat -c %Y "$dir")
                    current_time=$(date +%s)
                    diff=$(( (current_time - mod_time) / 86400 ))

                    if [ "$diff" -ge 60 ]; then
                        username=$(basename "$dir")
                        archive_file="/archives/${username}_archive.tar.gz"
                        
                        # Archive the workspace 
                        tar -czf "$archive_file" -C /home/lab_users "$username"
                        echo "Archived $username to $archive_file"

                        # Ask to delete original 
                        read -p "Delete original workspace for $username? (y/n): " confirm
                        if [ "$confirm" == "y" ]; then
                            rm -rf "$dir"
                            echo "Original workspace deleted."
                        fi
                    fi
                fi
            done
            ;;

        5)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo ""
done