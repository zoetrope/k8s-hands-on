package sub

import (
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var config struct {
	ListenAddr string `mapstructure:"listen-addr"`
	ContentDir string `mapstructure:"content-dir"`
	AllowCORS  bool   `mapstructure:"allow-cors"`
}

var rootCmd = &cobra.Command{
	Use:     "todo",
	Version: "0.1.0",
	Short:   "Todo Application",
	Long:    `Todo Application.`,

	RunE: func(cmd *cobra.Command, args []string) error {
		cmd.SilenceUsage = true
		return subMain()
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	fs := rootCmd.Flags()
	fs.StringVar(&config.ListenAddr, "listen-addr", ":8080", "The address the endpoint binds to")
	fs.StringVar(&config.ContentDir, "content-dir", "/dist", "The path of content files")
	fs.BoolVar(&config.AllowCORS, "allow-cors", false, "Allow CORS (for development)")

	viper.BindPFlag("listen-addr", fs.Lookup("listen-addr"))
	viper.BindPFlag("content-dir", fs.Lookup("content-dir"))
	viper.BindPFlag("allow-cors", fs.Lookup("allow-cors"))

	viper.AutomaticEnv()
	replacer := strings.NewReplacer("-", "_")
	viper.SetEnvKeyReplacer(replacer)

	if err := viper.Unmarshal(&config); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
